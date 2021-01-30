shader_type spatial;

void fragment() 
{
    METALLIC = 0.0;
    ROUGHNESS = 0.5;
    SPECULAR = 0.5;
    ALBEDO = COLOR.rgb;
}
