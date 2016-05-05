Shader ".ShaderTalk/Diffuse"
{
	Properties
	{
	_Color ("Main Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Pass
		{
		Tags { "LightMode" = "ForwardBase" }

		CGPROGRAM

		#pragma vertex vert
		#pragma fragment frag

		 #include "UnityCG.cginc"

		uniform float4 _LightColor0;
			// the color of the light source (from "Lighting.cginc")

		uniform float4 _Color; // define shader property for shaders

		struct vertexInput
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};

		struct vertexOutput
		{
			float4 pos : SV_POSITION;
			float4 col : COLOR;
		};

		vertexOutput vert (vertexInput input)
		{
			vertexOutput output;

			float4x4 modelMatrix = _Object2World;
			float4x4 modelMatrixInverse = _World2Object;

            float3 normalDirection = normalize(
               mul(
               float4(input.normal, 0.0), 
               modelMatrixInverse).xyz);
			float3 lightDirection = normalize (_WorldSpaceLightPos0.xyz);

			float3 diffuseReflection = _LightColor0.rgb * _Color.rgb
				* max(0.0, dot(normalDirection, lightDirection));

			output.col = float4(diffuseReflection, 1.0);
			output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
			return output;
		}

		fixed4 frag (vertexOutput input) : COLOR
		{
			return input.col;
		}
		ENDCG
		}
	}
	Fallback "Diffuse"
}