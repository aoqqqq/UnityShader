Shader "Unlit/1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Nuber ("num",float) = 0
       [HDR]_Color("Color", Color) = (1, 0, 0, 0)
         [HDR]_Color2("Color2", Color) = (1, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
            float2 _ScreenResolution;
            float _Nuber;
            float4 _Color;
            float4 _Color2;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv =v.uv;
              //  o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(0,0,0,1);
                fixed2 uv2 =i.uv*2-1;
                fixed2 uv3 =i.uv*2-1;
                uv3 = 1-uv3;
             
                //许多-1~1 的线段d
             for (int index = 1; index < 6 ;index++) 
              {   
                uv3 =frac(uv3*2);
                uv2 =frac(uv2*1.5);
                uv2 -=0.5;
                uv3 -= 0.5;

                fixed d = length(uv2);
                fixed d2 = length(uv3);

                d = sin(d*_Nuber+_Time*24/index)/8;  
                d = abs(d);
                d = smoothstep(0,0.2,d);
                d =0.01/d;
                col += fixed4(d,d,d,1);
                col*=_Color;
                d2 = sin(d2*_Nuber+_Time*24)/8;  
                d2 = abs(d2);
                d2 = smoothstep(0,0.2,d2);
                d2 =0.02/d2;
                col += (fixed4(d2,d2,d2,1)*_Color2);
              }
              
                // 
           
               //
                // fixed4 col = fixed4(0.02/0.01,0.02/0.01,0.02/0.01,1);
        
                return col;
            }
            ENDCG
        }
    }
}
