Shader "Unlit/2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color ("Color1",Color) = (0,0,0,0)
        [HDR]_Color2 ("Color1",Color) = (0,0,0,0)
        [HDR]_Color3 ("Color3",Color) = (0,0,0,0)
        _Bool ("isopen1", Float) = 0
        _Q ("Q", Float) = 0
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float _Q;
             fixed4 _Color3;
                fixed3 funz(fixed2 fuv , fixed3 todocolor)
             {
                fixed2 copy1 =fuv;
               //遮罩
               fixed2 copy2 =fuv;
                fixed z =length(copy1);
                fixed z2 =length(copy2);
                 z = sin(z*3+_Time*24)/8;
                 z = smoothstep(0.0,0.2,z);
                 fixed3 zz = fixed3(z,z,z);
                //todocolor *=exp(-zz);
                todocolor +=zz/_Q;
                todocolor*=_Color3;
                 return todocolor;
             }

             fixed3 fun(fixed2 fuv , fixed scale)
             {
                fixed3 sumcolor = fixed3(0.,0.,0.);
                        //这个函数能细分 --个人理解
                for (fixed index = 1; index < 6.; index++)
                {
                fuv = frac(fuv*scale);
                fuv -=0.5;
                fixed d = length(fuv);
                //      频率    速度    虚化
                d = sin(d*8.+_Time*24.)/8;
                d = abs(d);
                // 小于0.0=0 大于0.1=1
                d = smoothstep(0.0,0.1,d);
                // 因为uv是-1~1的范围 所以 uv越值越小亮度越亮
                d = 0.01/d;
                sumcolor += fixed3(d,d,d);
                }

                 return sumcolor;
             }

                //效果2
                fixed3 fun2(fixed2 fuv , fixed scale,bool isopen)
             {
                fixed3 sumcolor = fixed3(0.,0.,0.);
                        //这个函数能细分 --个人理解
                for (fixed index = 1; index < 6.; index++)
                {
                fuv = frac(fuv*scale);
                fuv -=0.5;
                fixed d = length(fuv);
                //      频率    速度    虚化
                d = isopen? sin(d*8.+_Time*24./index)/8: sin(d*8.+_Time*24.)/8;
                d = abs(d);
                // 小于0.0=0 大于0.1=1
                d = smoothstep(0.0,0.1,d);
                // 因为uv是-1~1的范围 所以 uv越值越小亮度越亮
                d = 0.01/d;
                sumcolor += fixed3(d,d,d);
                }
                 return sumcolor;
             }


             float _Bool;
            fixed4 _Color;
            fixed4 _Color2;
            fixed4 frag (v2f i) : SV_Target
            {
                // 原本uv是0~1 这个操作会使uv-1~1
                fixed2 uv1 = i.uv*2-1;
                fixed2 uv2 = 1-uv1;

                 fixed2 copy1 =uv1; 
               //遮罩
                fixed z =length(copy1);
                 z = sin(z*7+_Time*24)/8;
                 z = smoothstep(0.0,0.2,z);
                 fixed3 zz = fixed3(z,z,z);

                fixed3 allcolor = funz(uv1,fun(uv1,1.5))*_Color.rgb +funz(uv1, fun(uv2,1.5))*_Color2.rgb;
                fixed3 allcolor2 =funz(uv1,fun2(uv1,1.5,false))*_Color.rgb +funz(uv1, fun2(uv2,1.5,true))*_Color2.rgb;

               
                fixed4 col = fixed4(_Bool==0?allcolor:allcolor2,1);
                //fixed4 col = fixed4(z,z,z,1);
                return col;
            }
            ENDCG
        }
    }
}
