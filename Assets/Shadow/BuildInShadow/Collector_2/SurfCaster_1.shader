Shader "Tut/Shadow/BuildIn/Werid/SurfCaster_1" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_v("Alter Value",range(0,40))=1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	 
	// Pass to render object as a shadow caster
	Pass {
		Name "ShadowCaster"
		Tags { "LightMode" = "ShadowCaster" }
		
		Fog {Mode Off}
		ZWrite On ZTest LEqual Cull Off
		Offset 1, 1

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_shadowcaster
		#pragma fragmentoption ARB_precision_hint_fastest
		#include "UnityCG.cginc"
		
		float _v;
		struct v2f { 
		    //V2F_SHADOW_CASTER;
		    float4 pos : SV_POSITION; 
		    float4 hpos : TEXCOORD1;
		    float3 vec : TEXCOORD0;
		};
		
		v2f vert( appdata_base v )
		{
		    v2f o;
		    //TRANSFER_SHADOW_CASTER(o)
		    float4 vPos=v.vertex;
		    o.vec = mul( _Object2World, vPos).xyz- (_LightPositionRange.xyz);
		    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		    //
		    o.pos.z += unity_LightShadowBias.x; 
		    //float clamped = max(o.pos.z, 0.0);
		    float clamped = max(o.pos.z, -o.pos.w);
		    o.pos.z = lerp(o.pos.z, clamped, unity_LightShadowBias.y); 
		    o.hpos = o.pos;
		    return o;
		}
		
		float4 frag( v2f i ) : COLOR
		{
		    //SHADOW_CASTER_FRAGMENT(i)
		    float3 s=i.vec;
		    s.x*=_v;
		    s.z*=_v;
		    return EncodeFloatRGBA(sin(length(s))*_v*(_LightPositionRange.w));//.........................
		}
		ENDCG

		}
	}
	//FallBack "Diffuse"
}
