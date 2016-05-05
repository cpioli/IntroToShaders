Shader ".ShaderTalk/PerPixelLightingWithTexture" {
	Properties {
		_MainTex ("RGBA Texture For Material Color", 2D) = "white" {}
		_Color ("Diffuse Material Color", Color) = (1, 1, 1, 1)
		_SpecColor ("SpecularMaterialColor", Color) = (1,1,1,1)
		_Shininess ("Shininess", Float) = 10
	}
	SubShader {
		Pass {
			Tags { "LightMode" = "ForwardBase" }
				// pass for ambient light and first light source

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			uniform float4 _LightColor0;
				// color of light source (from "Lighting.cginc")

			// User-specified properties
			uniform sampler2D _MainTex;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;

			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float4 tex : TEXCOORD2;
			};


			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;

				output.posWorld = mul(modelMatrix, input.vertex);
				output.normalDir = normalize(
					mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				output.tex = input.texcoord;
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				float3 normalDirection = normalize(input.normalDir);

				float3 viewDirection = normalize(
					_WorldSpaceCameraPos - input.posWorld.xyz); //the camera position in world space minus the world
																//position of the vertex (cutting away the w component)
				float3 lightDirection;
				float attenuation;

				float4 textureColor = tex2D(_MainTex, input.tex.xy);

				if (0.0 == _WorldSpaceLightPos0.w) // if this is a directional light
				{
					attenuation = 1.0;
					lightDirection = 
						normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 vertexToLightSource =
						_WorldSpaceLightPos0.xyz - input.posWorld.xyz; //calculate the vertex of the incoming light ray
					float distance = length(vertexToLightSource); //calculate the distance of said light ray
					attenuation = 1.0 / distance; // linear attenuation
					lightDirection = normalize(vertexToLightSource);
				}

				float3 ambientLighting = textureColor.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

				float3 diffuseReflection = textureColor.rgb * attenuation * _LightColor0.rgb * _Color.rgb
					* max(0.0, dot(normalDirection, lightDirection));

				float3 specularReflection;
				if (dot(normalDirection, lightDirection) < 0.0)
				{
					specularReflection = float3(0.0, 0.0, 0.0);
					// no specular reflection
				}
				else
				{
					specularReflection = attenuation * _LightColor0.rgb
						* _SpecColor.rgb * (1.0 - textureColor.a)
							// for usual gloss maps: "... * textureColor.a"
						* pow(max(0.0, dot(
						reflect(-lightDirection, normalDirection),
						viewDirection)), _Shininess);
				}

				return float4(ambientLighting + diffuseReflection + specularReflection, 1.0);
			}

			ENDCG
		}

		Pass {
			Tags { "LightMode" = "ForwardAdd" }
				// the pass for additional light sources
			Blend One One //additive blending

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			uniform float4 _LightColor0;
				// color of light source (from "Lighting.cginc")

			// User-specified properties
			uniform sampler2D _MainTex;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;

			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float4 tex : TEXCOORD2;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;

				output.posWorld = mul(modelMatrix, input.vertex);
				output.normalDir = normalize(
					mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				output.tex = input.texcoord;
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				float3 normalDirection = normalize(input.normalDir);

				float3 viewDirection = normalize(
					_WorldSpaceCameraPos - input.posWorld.xyz);
				float3 lightDirection;
				float attenuation;

				float4 textureColor = tex2D(_MainTex, input.tex.xy);

				if (0.0 == _WorldSpaceLightPos0.w) // directional light?
				{
					attenuation = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 vertexToLightSource =
						_WorldSpaceLightPos0.xyz - input.posWorld.xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0 / distance;
					lightDirection = normalize(vertexToLightSource);
				}

				float3 diffuseReflection = textureColor.rgb
					* attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection));

				float3 specularReflection;
				if (dot(normalDirection, lightDirection) < 0.0) //the light source is not on the correct side
				{
					specularReflection = float3(0.0, 0.0, 0.0);
				}
				else
				{
					specularReflection = attenuation * _LightColor0.rgb
						* _SpecColor.rgb * (1.0 - textureColor.a)
							// for usual gloss maps: " ... * textureColor.a"
						* pow(max(0.0, dot(
						reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				}

				return float4(diffuseReflection + specularReflection, 1.0);
					// remember, no ambient lighting in this pass
			}

			ENDCG
		}
	}
	Fallback "Specular"
}
