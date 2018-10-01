﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/70-79/75_06_TBN_WN_2"
{
    Properties
    {
        _Normal ("Normal", 2D) = "bump" {}
    }
    
    SubShader
    {
        Pass 
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            sampler2D _Normal;
            float4 _Normal_ST;
            
            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };
            
            struct vertexOuput
            {
                float4 pos : SV_POSITION;
                float4 normalWorld : TEXCOORD0;
                float4 tangentWorld : TEXCOORD1;
                float3 binormalWorld : TEXCOORD2;
                float4 normalTexCoord : TEXCOORD3;
            };
            
            float3 normalFromColor(float4 col)
            {
                #if defined(UNITY_NO_DXT5nm)
                    return col.xyz * 2 - 1;
                #else
                    float3 normVal;
                    normVal = float3(col.a * 2 - 1, col.g * 2 - 1, 0.0);
                    normVal.z = sqrt(1 - dot(normVal, normVal));
                    return normVal;
                #endif
            }
            
            vertexOuput vert(vertexInput v)
            {
                vertexOuput o;
                UNITY_INITIALIZE_OUTPUT(vertexOuput, o);
                
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.normalTexCoord.xy = v.texcoord.xy * _Normal_ST.xy + _Normal_ST.zw;
                
                o.normalWorld = float4(normalize(mul(normalize(v.normal.xyz), (float3x3) unity_WorldToObject)), v.normal.w);
                o.tangentWorld = float4(normalize(mul((float3x3) unity_ObjectToWorld, v.tangent.xyz)), v.tangent.w);
                o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);
                
                return o;
            }
            
            float4 frag(vertexOuput i) : COLOR
            {
                float4 col = tex2D(_Normal, i.normalTexCoord);
                
                float3 norm = normalFromColor(col);
                
                float3x3 TBN = float3x3(i.tangentWorld.xyz, i.binormalWorld, i.normalWorld.xyz);
                float4 worldNorm = float4(normalize(mul(norm, TBN)), 0);
                
                return worldNorm;
            }
            ENDCG
        }
    }
}   