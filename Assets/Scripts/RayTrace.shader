Shader "Custom/RayTrace"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_noise("Noise", Range(0,0.5)) = 0.1
		_noise2("Noise2", Range(0,0.5)) = 0.1
		_noise3("Noise3", Range(0,0.5)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#define MIN		0.0
			#define MAX		16.0
			#define DELTA	0.01
			#define ITER	1000
			#define pi 3.14159265

			// based sample
			// http://glslsandbox.com/e#37071.2

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _noise;
			float _noise2;
			float _noise3;

			float3x3 rotZ(float a)
			{
				return float3x3(cos(a), -sin(a), 0,
					   sin(a), cos(a), 0,
					   0, 0, 1);
			}

	        float perlin(float3 p) {
	        	float3 i = floor(p);
	        	float4 a = dot(i, float3(1., 57., 21.)) + float4(0., 57., 21., 78.);
	        	float3 f = cos((p-i)*pi)*(-.5)+.5;
	        	a = lerp(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
	        	a.xy = lerp(a.xz, a.yw, f.y);
	        	return lerp(a.x, a.y, f.z);
	        }

			float sdBox( float3 p, float3 b )
			{
				float3 d = abs(p) - b;
				return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
			}

			float map(float3 p) {
				float t = 100.0;
				float w = 0.0;

				float temp = 2.4;

				float3 newP = fmod(p+(float3(0.2,0.0,0.0)),temp)-(temp*0.5)*2.0;
				float3 newP2 = fmod(p+(float3(-0.2,0.0,0.0)),temp)-(temp*0.5)*2.0;
				p = fmod(p,temp)-(temp*0.5)*2.0;
				w = sdBox(p,float3(0.1,_noise,0.1));
				t = min(t, w);

				w = sdBox(newP,float3(0.1,_noise2,0.1));
				t = min(t, w);

				w = sdBox(newP2,float3(0.1,_noise3,0.1));
				t = min(t, w);

				return t;
			}

			float castRay(float3 o,float3 d) {
				float delta = MAX;
				float t = MIN;
				for (int i = 0;i <= ITER;i += 1) {
					float3 p = o+d*t;
					delta = map(p);

					t += delta;
					if (t > MAX) {return MAX;}
					if (delta-DELTA <= 0.0) {return float(i);}
				}
				return MAX;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//fixed2 resolution = _ScreenParams;
				//fixed2 fragCord = i.uv*_ScreenParams;

				float2 p = i.uv;

				float3 o = float3(_Time.y*0.5, 0.0, 0.0);
				float3 d = normalize(float3(p.x,p.y,1.0));
				
				float t = castRay(o,d);
				float3 rp = o+d*t;

				float4 col;
				if (t < MAX) {
					t = 1.0-t/float(MAX);
					col = float4(t,t,t,1.0)*float4(1.0,0.5,0.5,1.0);
				} else {
					col = float4(1.0,1.0,1.0,1.0);
					//discard;
				}

				return col;
			}
			ENDCG
		}
	}
}