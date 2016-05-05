Shader ".ShaderTalk/TransparentTexture" {
	Properties {
		_MainTex ("RGBA Texture Image", 2D) = "white" {}
		_Cutoff ("AlphaCutoff", Float) = 0.5
	}
	SubShader {
		Pass {
			Cull Off // since the front will be partially transparent then we should not cull the back.

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform sampler2D _MainTex;
			uniform float _Cutoff;

			struct vertexInput {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.tex = input.texcoord;
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				float4 textureColor = tex2D(_MainTex, input.tex.xy);
				if(textureColor.a < _Cutoff) //if the alpha value is less than the user-specified threshold
				{
					discard;
				}
				return textureColor;
			}

			ENDCG
		}
	}
	Fallback "Unlit/Transparent Cutout"
}