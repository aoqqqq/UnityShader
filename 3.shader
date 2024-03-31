Shader "Unlit/3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale("Scale",float) = 4
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
            fixed sdBox( in fixed2 p, in fixed2 b )
            {
                 fixed2 d = abs(p)-b;
                 return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
            }

            //引入声明
            float _Scale;
            fixed4 frag (v2f i) : SV_Target
            {
                // 缩放uv使得 棋盘格可以细分
                fixed2 UV1 = i.uv*_Scale;
                //floor 函数可以忽略小数部分 如 2.2=2; 2.9=2
                //这时候 会忽略小数部分 只保留了UV范围内最大的1 
                //所以 x=1 y=1 这时候什么也不会显示 严格来说可能会有非常细的细线但是我们看不到
                //所以 想让图像显示最少_Scale最少得放大两倍 uv*2
                fixed x = floor(UV1.x);
                fixed y = floor(UV1.y);
                    if (y%2==0) 
                    {
                        y=0;
                    }
                fixed xy =x+y;
                // return fixed4(y,y,y,1);
                //默认颜色是白色
                fixed4 col =fixed4(1,1,1,1);
               
                 if (xy%2==0) {
                    //这的xy值可能是0 2 4 6 8 ...
                    
                    xy=1;//我们想让它成为黑色 也可以归一化或者啥都不干直接乘个黑色
                    //如果你要上色的话 直接xy=1 因为有0 这个可能归一化可能导致上色不全面
                    //上个色
                    col*=xy*fixed4(.02,0.04,0.27,1);
                }
                else
                {

                    //xy = 1;
                    //二选一即可 因为1 3 5 7 9.. 会出现前几个格格是正常显色(1) 后几个就会偏白
                    //5 7 9.. 直接 全白了
                    xy = normalize(xy);
                       col*=xy*fixed4(.98,0.34,0.5,1);
                }
                  // col = fixed4(xy,xy,xy,1);
          
                 return col;
            }
            ENDCG
        }
    }
}
