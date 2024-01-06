Shader "Playground/Wave"
{
    Properties
    {
        // Wave color : 0E87CC
        // Wave color from Acerola : 3A4851
        // Directional Light default color : FFF4D6
        [Header(Vertex Shader Properties)]
        [Header(X Axis)][Space][Space]
        _WaveAAmplitude ("Wave A Amplitude", Range(0.1, 1)) = 0.5
        _WaveAFrequency ("Wave A Frequency", Range(0.1, 0.5)) = 0.5
        _WaveASpeed ("Wave A Speed", Range(0.1, 1)) = 0.1

        [Space][Space]
        _WaveBAmplitude ("Wave B Amplitude", Range(0.1, 1)) = 0.1
        _WaveBFrequency ("Wave B Frequency", Range(0.1, 0.5)) = 0.5
        _WaveBSpeed ("Wave B Speed", Range(0.1, 1)) = 0.1


        [Header(Z Axis)][Space][Space]
        _WaveCAmplitude ("Wave C Amplitude", Range(0.1, 1)) = 0.2
        _WaveCFrequency ("Wave C Frequency", Range(0.1, 0.5)) = 0.5
        _WavCSpeed ("Wave C Speed", Range(0.1, 1)) = 0.1

        [Space][Space]
        _WaveDAmplitude ("Wave D Amplitude", Range(0.1, 1)) = 0.2
        _WaveDFrequency ("Wave D Frequency", Range(0.1, 0.5)) = 0.5
        _WaveDSpeed ("Wave D Speed", Range(0.1, 1)) = 0.1

        [Header(Fragment Shader Properties)][Space]
        [Header(Lighting)][Space]
        _WaveColor ("Wave Color", Color) = (0.05490194, 0.5294118, 0.8, 1)
        _Smoothness ("Smoothness", Range(10, 100)) = 50
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags {
				"LightMode" = "ForwardBase"
			}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityStandardBRDF.cginc"
            #include "AutoLight.cginc"

            #define TAU 6.2831853

            float _WaveAAmplitude, _WaveAFrequency, _WaveASpeed;
            float _WaveBAmplitude, _WaveBFrequency, _WaveBSpeed;
            float _WaveCAmplitude, _WaveCFrequency, _WaveCSpeed;
            float _WaveDAmplitude, _WaveDFrequency, _WaveDSpeed;            

            float4 _WaveColor;
            float _Smoothness;
            
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                float wave1 = v.vertex.x * _WaveAFrequency + _Time.y * _WaveASpeed;
                float wave2 = v.vertex.x * _WaveBFrequency - _Time.y * _WaveBSpeed;
                float wave3 = v.vertex.z * _WaveCFrequency + _Time.y * _WaveCSpeed;
                float wave4 = v.vertex.z * _WaveDFrequency - _Time.y * _WaveDSpeed;
                float wave5 = v.vertex.x * _WaveAFrequency + v.vertex.z * _WaveCFrequency + _Time.y * _WaveASpeed;
                float wave6 = v.vertex.z * _WaveDFrequency + v.vertex.x * _WaveBFrequency - _Time.y * _WaveDSpeed;

                float waveLength1 = _WaveASpeed / _WaveAFrequency;
                float waveLength2 = _WaveBSpeed / _WaveBFrequency;
                float waveLength3 = _WaveCSpeed / _WaveCFrequency;
                float waveLength4 = _WaveDSpeed / _WaveDFrequency;
                float waveLength5 = _WaveASpeed / (_WaveAFrequency + _WaveCFrequency);
                float waveLength6 = _WaveDSpeed / (_WaveDFrequency + _WaveBFrequency);

                float3 tangent1 = normalize(float3(1, waveLength1 * _WaveAAmplitude * cos(wave1), 0));
                float3 tangent2 = normalize(float3(1, waveLength2 * _WaveBAmplitude * cos(wave2), 0));
                float3 tangent3 = normalize(float3(1, waveLength3 * _WaveCAmplitude * cos(wave3), 0));
                float3 tangent4 = normalize(float3(1, waveLength4 * _WaveDAmplitude * cos(wave4), 0));
                float3 tangent5 = normalize(float3(1, waveLength5 * _WaveAAmplitude * cos(wave5), 0));
                float3 tangent6 = normalize(float3(1, waveLength6 * _WaveDAmplitude * cos(wave6), 0));
                
                float3 normal1 = float3(-tangent1.y, tangent1.x, 0);
                float3 normal2 = float3(-tangent2.y, tangent2.x, 0);
                float3 normal3 = float3(-tangent3.y, tangent3.x, 0);
                float3 normal4 = float3(-tangent4.y, tangent4.x, 0);
                float3 normal5 = float3(-tangent5.y, tangent5.x, 0);
                float3 normal6 = float3(-tangent6.y, tangent6.x, 0);

                v.vertex.y += _WaveAAmplitude * sin(wave1);
                v.vertex.y += _WaveBAmplitude * sin(wave2);
                v.vertex.y += _WaveCAmplitude * sin(wave3);
                v.vertex.y += _WaveDAmplitude * sin(wave4);
                v.vertex.y += _WaveAAmplitude * sin(wave5);
                v.vertex.y += _WaveDAmplitude * sin(wave6);

                v.normal += normal1;
                v.normal += normal2;
                v.normal += normal3;
                v.normal += normal4;
                v.normal += normal5;
                v.normal += normal6;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                i.normal = normalize(i.normal);
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfVector = normalize(lightDir + viewDir);

                float3 lightColor = _LightColor0.rgb;

                float3 ambient = float3(0.0f, 0.0f, 0.1f);
                float3 diffuse = lightColor * _WaveColor * DotClamped(lightDir, i.normal) * 0.5f + 0.5f;
                diffuse *= diffuse;
                float3 specular = lightColor * pow(DotClamped(halfVector, i.normal), _Smoothness);

                float4 outCol = float4(saturate(ambient + diffuse + specular), 1);
                return outCol;
            }
            ENDCG
        }
    }
}
