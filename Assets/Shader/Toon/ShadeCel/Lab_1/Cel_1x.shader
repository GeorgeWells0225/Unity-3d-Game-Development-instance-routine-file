Shader "Tut/Shader/Toon/Cel_1x" {
	Properties {
		_Color("Main Color",color)=(1,1,1,1)
		_Outline("Thick of Outline",range(0,0.1))=0.02
		_Factor("Factor",range(0,1))=0.5
		_ToonEffect("Toon Effect",range(0,1))=0.5
		_Steps("Steps of toon",range(0,9))=3
	}
	SubShader {
		pass{
		Tags{"LightMode"="Always"}
		Cull Front
		ZWrite On
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		float _Outline;
		float _Factor;
		struct v2f {
			float4 pos:SV_POSITION;
		};

		v2f vert (appdata_full v) {
			v2f o;
			float3 dir=normalize(v.vertex.xyz);
			float3 dir2=v.normal;
			float D=dot(dir,dir2);
			dir=dir*sign(D);
			dir=dir*_Factor+dir2*(1-_Factor);
			v.vertex.xyz+=dir*_Outline;
			o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
			return o;
		}
		float4 frag(v2f i):COLOR
		{
			float4 c=0;
			return c;
		}
		ENDCG
		}//end of pass
		pass{
		Tags{"LightMode"="ForwardBase"}
		Cull Back
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		float4 _LightColor0;
		float4 _Color;
		float _Steps;
		float _ToonEffect;

		struct v2f {
			float4 pos:SV_POSITION;
			float3 lightDir:TEXCOORD0;
			float3 viewDir:TEXCOORD1;
			float3 normal:TEXCOORD2;
		};

		v2f vert (appdata_full v) {
			v2f o;
			o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
			o.normal=v.normal;
			o.lightDir=ObjSpaceLightDir(v.vertex);
			o.viewDir=ObjSpaceViewDir(v.vertex);

			return o;
		}
		float4 frag(v2f i):COLOR
		{
			float4 c=1;
			float3 N=normalize(i.normal);
			float3 viewDir=normalize(i.viewDir);
			float3 lightDir=normalize(i.lightDir);
			float diff=dot(N,i.lightDir);
			diff=(diff+1)/2;
			diff=smoothstep(0,1,diff);
			float toon=floor(diff*_Steps)/_Steps;
			diff=lerp(diff,toon,_ToonEffect);

			c=_Color*_LightColor0*(diff);
			return c;
		}
		ENDCG
		}//
		pass{
		Tags{"LightMode"="ForwardAdd"}
		Blend One One
		Cull Back
		ZWrite Off
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		float4 _LightColor0;
		float4 _Color;
		float _Steps;
		float _ToonEffect;

		struct v2f {
			float4 pos:SV_POSITION;
			float3 lightDir:TEXCOORD0;
			float3 viewDir:TEXCOORD1;
			float3 normal:TEXCOORD2;
		};

		v2f vert (appdata_full v) {
			v2f o;
			o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
			o.normal=v.normal;
			o.viewDir=ObjSpaceViewDir(v.vertex);
			o.lightDir=_WorldSpaceLightPos0-v.vertex;

			return o;
		}
		float4 frag(v2f i):COLOR
		{
			float4 c=1;
			float3 N=normalize(i.normal);
			float3 viewDir=normalize(i.viewDir);
			float dist=length(i.lightDir);
			float3 lightDir=normalize(i.lightDir);
			float diff=dot(N,i.lightDir);
			diff=(diff+1)/2;
			diff=smoothstep(0,1,diff);

			half3 h = normalize (lightDir + viewDir);
			float nh = max (0, dot (N, h));
			float spec = pow (nh, 32.0);

			float atten=1/(dist);
			float toon=floor(atten*_Steps)/_Steps;
			atten=lerp(atten,toon,_ToonEffect);
			c=_Color*_LightColor0*(diff+spec)*atten;
			return c;
		}
		ENDCG
		}//
	} 
}
