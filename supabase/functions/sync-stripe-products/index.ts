import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.21.0';
import Stripe from 'https://esm.sh/stripe@12.0.0?target=deno';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Create a Supabase client with service role key
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    const supabase = createClient(supabaseUrl!, supabaseServiceKey!);

    // Create a Stripe client
    const stripeKey = Deno.env.get('STRIPE_SECRET_KEY');
    const stripe = new Stripe(stripeKey!, {
      apiVersion: '2023-10-16',
    });

    // Get the authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      throw new Error('Missing authorization header');
    }

    // Verify user is admin (optional - you can remove this check if needed)
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader.replace('Bearer ', '')
    );

    if (authError || !user) {
      throw new Error('User not authenticated');
    }

    // Get all active products from Stripe
    const products = await stripe.products.list({
      active: true,
      limit: 100,
    });

    // Get all prices for active products
    const prices = await stripe.prices.list({
      active: true,
      limit: 100,
    });

    // Sync products with subscription_plans table
    for (const product of products.data) {
      // Find prices for this product
      const productPrices = prices.data.filter(p => p.product === product.id);
      
      for (const price of productPrices) {
        // Skip if not a subscription price
        if (price.type !== 'recurring') continue;
        
        // Determine billing interval
        const billingInterval = price.recurring?.interval || 'month';
        const intervalMap: { [key: string]: string } = {
          'month': 'monthly',
          'year': 'yearly',
        };
        
        // Prepare plan data
        const planData = {
          name: product.name,
          description: product.description || '',
          price: price.unit_amount ? price.unit_amount / 100 : 0, // Convert from cents
          billing_interval: intervalMap[billingInterval] || 'monthly',
          stripe_price_id: price.id,
          is_active: product.active && price.active,
        };

        // Check if plan already exists with this stripe_price_id
        const { data: existingPlan } = await supabase
          .from('subscription_plans')
          .select('id')
          .eq('stripe_price_id', price.id)
          .single();

        if (existingPlan) {
          // Update existing plan
          const { error } = await supabase
            .from('subscription_plans')
            .update(planData)
            .eq('id', existingPlan.id);

          if (error) {
            console.error('Error updating plan:', error);
          }
        } else {
          // Create new plan
          const { error } = await supabase
            .from('subscription_plans')
            .insert(planData);

          if (error) {
            console.error('Error creating plan:', error);
          }
        }
      }
    }

    // Deactivate plans that no longer exist in Stripe
    const { data: allPlans } = await supabase
      .from('subscription_plans')
      .select('id, stripe_price_id')
      .not('stripe_price_id', 'is', null);

    if (allPlans) {
      const activeStripePriceIds = prices.data.map(p => p.id);
      
      for (const plan of allPlans) {
        if (plan.stripe_price_id && !activeStripePriceIds.includes(plan.stripe_price_id)) {
          // Deactivate plan that no longer exists in Stripe
          const { error } = await supabase
            .from('subscription_plans')
            .update({ is_active: false })
            .eq('id', plan.id);

          if (error) {
            console.error('Error deactivating plan:', error);
          }
        }
      }
    }

    return new Response(
      JSON.stringify({
        message: 'Stripe products synced successfully',
        products_synced: products.data.length,
        prices_synced: prices.data.length,
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
        status: 200,
      }
    );
  } catch (error) {
    console.error('Sync Stripe products error:', error);
    return new Response(
      JSON.stringify({
        error: error.message,
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
        status: 400,
      }
    );
  }
});