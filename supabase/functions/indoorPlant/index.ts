import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  try {
    const response = await fetch("https://api.nongsaro.go.kr/service/plant/list?size=300");
    const json = await response.json();

    const plantList = json.data.map((item: any) => ({
      id: item.id,
      name: item.name,
      image_url: item.imageUrl,
      high_res_image_url: item.highResImageUrl ?? null,
      category: item.category,
    }));

    const { data, error } = await supabase
      .from("plants_summary")
      .insert(plantList)
      .select();

    if (error) throw error;

    return new Response(
      JSON.stringify({ message: "Inserted successfully", count: data.length }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
