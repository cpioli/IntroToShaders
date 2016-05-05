Shader ".ShaderTalk/SingleTextureShader" {
	Properties {
		_MainTex ("Texture Image", 2D) = "white" {}
			// a 2D texture property named "_MainTex"
			// should be labeled "Texture Image" in Unity's UI
			// By default we use the built-in texture "white"
			// alterantive built-in textures: "black", "gray", and "bump"
	}
	SubShader {
		Pass {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform sampler2D _MainTex;
			   // a uniform variable refering to the property above
			   // (it's only a small integer that specifies a "texture
			   // unit", which has the texture image "bound" to it;
			   // Unity takes care of this).
			uniform float4 _MainTex_ST;
				// tiling and offset parameters of property "_MainTex"

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
					// Unity provides default longitude latitude-like
					// texture coordinates at all vertices of a
					// sphere mesh as the input parameter
					// "input.texcoord" with semantic "TEXCOORD0".
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}
			float4 frag(vertexOutput input) : COLOR
			{
				//return tex2D(_MainTex, input.tex.xy);
				return tex2D(_MainTex, _MainTex_ST.xy * input.tex.xy + _MainTex_ST.zw);
					// this looks up the color of the texture image
					// specified by the uniform "_MainTex" at the position
					// specified by "input.tex.x" and "input.tex.y" and return it
					// the second call to tex2D allows the texture to be offset
			}

			ENDCG
		}
	}
	Fallback "Unlit/Texture"
}