Includes = {
	"cw/pdxmesh.fxh"
	"cw/utility.fxh"
	"cw/shadow.fxh"
	"cw/camera.fxh"
	"cw/heightmap.fxh"
	"cw/pdxterrain.fxh"
	"jomini/jomini_fog.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_fog_of_war.fxh"
	"jomini/jomini_water.fxh"
	"jomini/jomini_mapobject.fxh"
	"constants.fxh"
	"standardfuncsgfx.fxh"
	"lowspec.fxh"
	"dynamic_masks.fxh"

	#EK2
	"bordercolor.fxh"
	#END-EK2
}

PixelShader =
{
	TextureSampler DiffuseMap
	{
		Index = 0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler PropertiesMap
	{
		Index = 1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler NormalMap
	{
		Index = 2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}	
	TextureSampler LightIndexMap
	{
		Index = 3
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler LightDataMap
	{
		Index = 4
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler UniqueMap
    {
		Index = 5
        MagFilter = "Linear"
        MinFilter = "Linear"
        MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
    }
	TextureSampler EnvironmentMap
	{
		Ref = JominiEnvironmentMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		Type = "Cube"
	}
	TextureSampler ShadowTexture
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		CompareFunction = less_equal
		SamplerType = "Compare"
	}
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	#TextureSampler TerrainDiffuseArray
	#{
	#	Ref = PdxTerrainTextures0
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Wrap"
	#	SampleModeV = "Wrap"
	#	type = "2darray"
	#}
	#TextureSampler TerrainNormalsArray
	#{
	#	Ref = PdxTerrainTextures1
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Wrap"
	#	SampleModeV = "Wrap"
	#	type = "2darray"
	#}
	#TextureSampler TerrainMaterialArray
	#{
	#	Ref = PdxTerrainTextures2
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Wrap"
	#	SampleModeV = "Wrap"
	#	type = "2darray"
	#}
	#TextureSampler TerrainColorMapTexture
	#{
	#	Ref = PdxTerrainColorMap
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Clamp"
	#	SampleModeV = "Clamp"
	#}
	TextureSampler FlagTexture
	{
		Ref = PdxMeshCustomTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}

	# MOD(map-skybox)
	TextureSampler SkyboxSample
	{
		Index = 12
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		Type = "Cube"
		File = "gfx/map/environment/SkyBox.dds"
		srgb = yes
	}
	# END MOD
}

VertexStruct VS_OUTPUT
{
    float4 Position			: PDX_POSITION;
	float3 Normal			: TEXCOORD0;
	float3 Tangent			: TEXCOORD1;
	float3 Bitangent		: TEXCOORD2;
	float2 UV0				: TEXCOORD3;
	float2 UV1				: TEXCOORD4;
	float3 WorldSpacePos	: TEXCOORD5;
	uint InstanceIndex 	: TEXCOORD6;
};

#ConstantBuffer( 4 )
#{
#	float4 AtlasCoordinate;
#	float vUVAnimSpeed;
#};


VertexShader =
{
	Code
	[[
		VS_OUTPUT ConvertOutput( VS_OUTPUT_PDXMESH In )
		{
			VS_OUTPUT Out;
			
			Out.Position = In.Position;
			Out.Normal = In.Normal;
			Out.Tangent = In.Tangent;
			Out.Bitangent = In.Bitangent;
			Out.UV0 = In.UV0;
			Out.UV1 = In.UV1;
			Out.WorldSpacePos = In.WorldSpacePos;

			#if defined( SELECTION_MARKER )
				float2 UV = Out.UV0;
				float Rotation = GlobalTime * 1.0f;
				float mid = 0.5f;

				// rotation
				Out.UV0 = float2(
					cos( Rotation ) * ( UV.x - mid ) + sin( Rotation ) * ( UV.y - mid ) + mid,
					cos( Rotation ) * ( UV.y - mid ) - sin( Rotation ) * ( UV.x - mid ) + mid
				);
			#endif

			return Out;
		}
		
		void CalculateSineAnimation( float2 UV, inout float3 Position, inout float3 Normal, inout float4 Tangent )
		{
			const float LARGE_WAVE_FREQUENCY = 3.14f;	//I guess it sort of makes it look like the wind is changing direction
			const float SMALL_WAVE_FREQUENCY = 7.0f;	//Higher values simulates higher wind speeds / more turbulence
			const float WAVE_LENGTH_POW = 2.0f;			//Higher values gives higher frequency at the end of the flag
			const float WAVE_LENGTH_INV_SCALE = 7.0f;	//Higher values gives higher frequency overall
			const float WAVE_SCALE = 0.25f;				//Higher values gives a stretchier flag
			const float ANIMATION_SPEED = 1.0f;			//SPEED!
			
			float Time = GlobalTime * 1.0f;
			float LargeWave = sin( Time * LARGE_WAVE_FREQUENCY );
			
			float SmallWaveV = Time * SMALL_WAVE_FREQUENCY - pow(UV.x,WAVE_LENGTH_POW) * WAVE_LENGTH_INV_SCALE;
			float SmallWaveD = -( WAVE_LENGTH_POW * pow(UV.x, WAVE_LENGTH_POW-1) * WAVE_LENGTH_INV_SCALE );
			float SmallWave = sin( SmallWaveV );
			
			float CombinedWave = SmallWave + LargeWave;
			
			float Wave = WAVE_SCALE * UV.x * CombinedWave;
			
			float Derivative = WAVE_SCALE * ( LargeWave + SmallWave + cos( SmallWaveV ) * SmallWaveD );
			
			
			float2 WaveTangent = normalize( float2( 1.0f, Derivative ) );
			float3 AnimationDir = cross( Tangent.xyz, float3(0,1,0) );
			Position += AnimationDir * Wave;
			Tangent = float4( WaveTangent.x, 0.0f, WaveTangent.y, 1.0f );
			float FlipNormal = cross( Tangent.xyz, Normal ).y;
			float3 WaveNormal = float3( WaveTangent.y, 0.0f, -WaveTangent.x ) * FlipNormal;
			float WaveNormalStrength = 0.3;
			Normal = lerp( Normal, WaveNormal, WaveNormalStrength ); // wave normal strength
		}
	]]
	
	MainCode VS_standard
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				Out.InstanceIndex = Input.InstanceIndices.y;
				return Out;
			}
		]]
	}
	
	MainCode VS_mapobject
	{
		Input = "VS_INPUT_PDXMESH_MAPOBJECT"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShader( PdxMeshConvertInput( Input ), 0/*Skinning data not supported*/, UnpackAndGetMapObjectWorldMatrix( Input.InstanceIndex24_Opacity8 ) ) );
				Out.InstanceIndex = Input.InstanceIndex24_Opacity8;
				return Out;
			}
		]]
	}
	
	MainCode VS_sine_animation
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				#ifdef PDX_MESH_UV1
				CalculateSineAnimation( Input.UV1, Input.Position, Input.Normal, Input.Tangent );
				#endif
				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				Out.InstanceIndex = Input.InstanceIndices.y;
				return Out;
			}
		]]
	}
	MainCode VS_sine_animation_shadow
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT_PDXMESHSHADOWSTANDARD"
		Code
		[[
			PDX_MAIN
			{
				#ifdef PDX_MESH_UV1
				CalculateSineAnimation( Input.UV1, Input.Position, Input.Normal, Input.Tangent );
				#endif
				return PdxMeshVertexShaderShadowStandard( Input );
			}
		]]
	}
}

PixelShader =
{
	Code
	[[
	#if defined( COA ) || defined( USER_COLOR )
		static const int USER_DATA_PRIMARY_COLOR = 0;
		static const int USER_DATA_SECONDARY_COLOR = 1;
		static const int USER_DATA_ATLAS_SLOT = 2;
	#endif
		float4 GetUserData( uint InstanceIndex, int DataOffset )
		{
			return Data[ InstanceIndex + PDXMESH_USER_DATA_OFFSET + DataOffset ];
		}
		
		float GetOpacity( uint InstanceIndex )
		{
			#ifdef JOMINI_MAP_OBJECT
				return UnpackAndGetMapObjectOpacity( InstanceIndex );
			#else
				return PdxMeshGetOpacity( InstanceIndex );
			#endif
		}
		
		float2 MirrorOutsideUV(float2 UV)
		{
			if ( UV.x < 0.0 ) UV.x = -UV.x;
			else if ( UV.x > 1.0 ) UV.x = 2.0 - UV.x;
			if ( UV.y < 0.0 ) UV.y = -UV.y;
			else if ( UV.y > 1.0 ) UV.y = 2.0 - UV.y;
			return UV;
		}
	]]

	# MOD(map-skybox)
	MainCode SKYX_PS_sky
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float3 FromCameraDir = normalize(Input.WorldSpacePos - CameraPosition);
				float4 CubemapSample = PdxTexCube(SkyboxSample, FromCameraDir);

				return CubemapSample;
			}
		]]
	}
	# END MOD

	MainCode PS_standard
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[

		//EK2	
		float3 OverlayNormal( in float3 Base, in float3 Overlay )
		{
			float3 Normal = Base;
			Normal.xy += Overlay.xy;
			Normal.z *= Overlay.z;
			return Normal;
		}
		//END-EK2

			#if defined( ATLAS )
				#ifndef DIFFUSE_UV_SET
					#define DIFFUSE_UV_SET Input.UV1
				#endif
				
				#ifndef NORMAL_UV_SET
					#define NORMAL_UV_SET Input.UV1
				#endif
				
				#ifndef PROPERTIES_UV_SET
					#define PROPERTIES_UV_SET Input.UV1
				#endif
				
				#ifndef UNIQUE_UV_SET
					#define UNIQUE_UV_SET Input.UV0
				#endif
			#else
				#ifndef DIFFUSE_UV_SET
					#define DIFFUSE_UV_SET Input.UV0
				#endif
				
				#ifndef NORMAL_UV_SET
					#define NORMAL_UV_SET Input.UV0
				#endif
				
				#ifndef PROPERTIES_UV_SET
					#define PROPERTIES_UV_SET Input.UV0
				#endif
			#endif
			#if defined( COA )
				#ifndef UNIQUE_UV_SET
					#define UNIQUE_UV_SET Input.UV1
				#endif
			#endif
			
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( DiffuseMap, DIFFUSE_UV_SET );
				
				#if defined( PDX_MESH_UV1 ) && defined( TILING_AO )
					Diffuse.rgb *= PdxTex2D( DiffuseMap, Input.UV1 ).a;
					Diffuse.a = 1.0f;
				#endif
				
				Diffuse.a = PdxMeshApplyOpacity( Diffuse.a, Input.Position.xy, GetOpacity( Input.InstanceIndex ) );
				
				float4 Properties = PdxTex2D( PropertiesMap, PROPERTIES_UV_SET );
				#if defined( LOW_SPEC_SHADERS )
					float3 Normal = Input.Normal;
				#else
					float3 NormalSample = UnpackRRxGNormal( PdxTex2D( NormalMap, NORMAL_UV_SET ) );
				
					float3x3 TBN = Create3x3( normalize( Input.Tangent ), normalize( Input.Bitangent ), normalize( Input.Normal ) );
					float3 Normal = normalize( mul( NormalSample, TBN ) );
				#endif
				
				float3 UserColor = float3( 1.0f, 1.0f, 1.0f );				
				
				#if defined( USER_COLOR )
					float3 UserColor1 = GetUserData( Input.InstanceIndex, USER_DATA_PRIMARY_COLOR ).rgb;
					float3 UserColor2 = GetUserData( Input.InstanceIndex, USER_DATA_SECONDARY_COLOR ).rgb;
					
					UserColor = lerp( UserColor, UserColor1, Properties.r );
					UserColor = lerp( UserColor, UserColor2, PdxTex2D( NormalMap, NORMAL_UV_SET ).b );
				#endif
				#if defined( COA ) && !defined( LOW_SPEC_SHADERS )
					float4 CoAAtlasSlot = GetUserData( Input.InstanceIndex, USER_DATA_ATLAS_SLOT );
					float2 FlagCoords = CoAAtlasSlot.xy + ( MirrorOutsideUV( Input.UV1 ) * CoAAtlasSlot.zw );
					UserColor = lerp( UserColor, PdxTex2D( FlagTexture, FlagCoords ).rgb, Properties.r );
				#endif
				Diffuse.rgb *= UserColor;
				
				#if defined( ATLAS )
					float4 Unique = PdxTex2D( UniqueMap, UNIQUE_UV_SET );
					
					// blend normals, commented out now since we never use NormalSample after this point
					// float3 UniqueNormalSample = UnpackRRxGNormal( Unique );
					// NormalSample = ReorientNormal( UniqueNormalSample, NormalSample );
					
					// multiply AO
					Diffuse.rgb *= Unique.bbb;
				#endif

				float2 ColorMapCoords =  Input.WorldSpacePos.xz *  WorldSpaceToTerrain0To1;

				//EK2 - APPLY TERRAIN TEXTURE TO MESH
				#if defined( APPLY_TERRAIN_TEXTURE )

					float2 WorldSpacePosXZ = Input.WorldSpacePos.xz;
					float2 WorldSpaceToDetail = WorldSpaceToTerrain0To1;

					float2 DetailCoordinates = WorldSpacePosXZ * WorldSpaceToDetail;
					float2 DetailCoordinatesScaled = DetailCoordinates * DetailTextureSize;
					float2 DetailCoordinatesScaledFloored = floor( DetailCoordinatesScaled );
					float2 DetailCoordinatesFrac = DetailCoordinatesScaled - DetailCoordinatesScaledFloored;
					DetailCoordinates = DetailCoordinatesScaledFloored * DetailTexelSize + DetailTexelSize * 0.5;
					
					float4 Factors = float4(
						(1.0 - DetailCoordinatesFrac.x) * (1.0 - DetailCoordinatesFrac.y),
						DetailCoordinatesFrac.x * (1.0 - DetailCoordinatesFrac.y),
						(1.0 - DetailCoordinatesFrac.x) * DetailCoordinatesFrac.y,
						DetailCoordinatesFrac.x * DetailCoordinatesFrac.y
					);
					
					float4 DetailIndex = PdxTex2D( DetailIndexTexture, DetailCoordinates ) * 255.0;
					float4 DetailMask = PdxTex2D( DetailMaskTexture, DetailCoordinates ) * Factors[0];
					
					float2 Offsets[3];
					Offsets[0] = float2( DetailTexelSize.x, 0.0 );
					Offsets[1] = float2( 0.0, DetailTexelSize.y );
					Offsets[2] = float2( DetailTexelSize.x, DetailTexelSize.y );
					
					for ( int k = 0; k < 3; ++k )
					{
						float2 DetailCoordinates2 = DetailCoordinates + Offsets[k];
						
						float4 DetailIndices = PdxTex2DLod0( DetailIndexTexture, DetailCoordinates2 ) * 255.0;
						float4 DetailMasks = PdxTex2DLod0( DetailMaskTexture, DetailCoordinates2 ) * Factors[k+1];
						
						for ( int i = 0; i < 4; ++i )
						{
							for ( int j = 0; j < 4; ++j )
							{
								if ( DetailIndex[j] == DetailIndices[i] )
								{
									DetailMask[j] += DetailMasks[i];
								}
							}
						}
					}

					float2 DetailUV = CalcDetailUV( WorldSpacePosXZ );

					float2 DDX = ddx(DetailUV);
					float2 DDY = ddy(DetailUV);

					
			float4 DetailTexture0 = PdxTex2DGrad( DetailTextures, float3( DetailUV, DetailIndex[0] ), DDX, DDY ) * smoothstep( 0.0, 0.1, DetailMask[0] );
			float4 DetailTexture1 = PdxTex2DGrad( DetailTextures, float3( DetailUV, DetailIndex[1] ), DDX, DDY ) * smoothstep( 0.0, 0.1, DetailMask[1] );
			float4 DetailTexture2 = PdxTex2DGrad( DetailTextures, float3( DetailUV, DetailIndex[2] ), DDX, DDY ) * smoothstep( 0.0, 0.1, DetailMask[2] );
			float4 DetailTexture3 = PdxTex2DGrad( DetailTextures, float3( DetailUV, DetailIndex[3] ), DDX, DDY ) * smoothstep( 0.0, 0.1, DetailMask[3] );
					
					float4 BlendFactors = CalcHeightBlendFactors( float4( DetailTexture0.a, DetailTexture1.a, DetailTexture2.a, DetailTexture3.a ), DetailMask, DetailBlendRange );
					//BlendFactors = DetailMask;
					
					float3 DetailDiffuseHeight =DetailTexture0.rgb * BlendFactors.x + 
									DetailTexture1.rgb * BlendFactors.y + 
									DetailTexture2.rgb * BlendFactors.z + 
									DetailTexture3.rgb * BlendFactors.w;
					
					float4 DetailMaterial = vec4( 0.0 );
					float4 DetailNormalSample = vec4( 0.0 );

					for ( int i = 0; i < 4; ++i )
					{
						float BlendFactor = BlendFactors[i];
						if ( BlendFactor > 0.0 )
						{
							float3 ArrayUV = float3( DetailUV, DetailIndex[i] );
							float4 NormalTexture = PdxTex2DGrad( NormalTextures, ArrayUV, DDX, DDY );
							float4 MaterialTexture = PdxTex2DGrad( MaterialTextures, ArrayUV, DDX, DDY );

							DetailNormalSample += NormalTexture * BlendFactor;
							DetailMaterial += MaterialTexture * BlendFactor;
						}
					}

					////////////////////////////////////////////////////////////////////////

					float3 FlatMap = PdxTex2D(FlatMapTexture,float2(ColorMapCoords.x,1.0f-ColorMapCoords.y)).rgb;
					float3 ColorMap = PdxTex2D(ColorTexture,float2(ColorMapCoords.x,1.0f-ColorMapCoords.y)).rgb;

					Diffuse.rgb = GetOverlay( DetailDiffuseHeight.rgb, ColorMap, ( 1 - DetailMaterial.r ) ).rgb;

					
					float3 BorderColor;
					float BorderPreLightingBlend;
					float BorderPostLightingBlend;
					GetBorderColorAndBlendGame( Input.WorldSpacePos.xz, FlatMap, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );

					float4 BaseDiffuse = PdxTex2D( DiffuseMap, DIFFUSE_UV_SET );

					Diffuse.rgb = lerp(Diffuse.rgb,BaseDiffuse.rgb, BaseDiffuse.a);
					
					Diffuse.rgb = lerp( Diffuse.rgb, BorderColor, BorderPreLightingBlend );

					//OPTION 1: SMOOTHER TRANSITION
					Normal = ReorientNormal( UnpackRRxGNormal( DetailNormalSample ).xyz, Normal );

					//OPTION 2: MORE DIFFERENT?
					//Normal = ReorientNormal( Normal, UnpackRRxGNormal( DetailNormalSample ).xyz );

					Properties = lerp(DetailMaterial, Properties, BaseDiffuse.a);
					
				#endif
				//END-EK2




				#if defined( APPLY_WINTER )
					Diffuse.rgb = ApplyDynamicMasksDiffuse( Diffuse.rgb, Normal, ColorMapCoords );
				#endif
				
				SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Properties.a, Properties.g, Properties.b );
				#if defined( LOW_SPEC_SHADERS )
					SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, 1.0 );
					float3 Color = CalculateSunLightingLowSpec( MaterialProps, LightingProps );
				#else
					SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTexture );
					float3 Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
				#endif
				
				#ifndef UNDERWATER
					Color = ApplyFogOfWar( Color, Input.WorldSpacePos, FogOfWarAlpha );
					Color = ApplyDistanceFog( Color, Input.WorldSpacePos );
				#endif
				
				float Alpha = Diffuse.a;
				#ifdef UNDERWATER
					clip( _WaterHeight - Input.WorldSpacePos.y + 0.1 ); // +0.1 to avoid gap between water and mesh
				
					Alpha = CompressWorldSpace( Input.WorldSpacePos );
				#endif
				
				DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );
				
				return float4( Color, Alpha );
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = no
}

BlendState alpha_blend
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}

BlendState alpha_to_coverage
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	AlphaToCoverage = yes
}

DepthStencilState DepthStencilState
{
	StencilEnable = yes
	FrontStencilPassOp = replace
	StencilRef = 1
}

DepthStencilState depth_no_write
{
	DepthEnable = yes
	DepthWriteEnable = no
}

RasterizerState ShadowRasterizerState
{
	DepthBias = 40000
	SlopeScaleDepthBias = 2
}

RasterizerState SelectionRasterizerState
{
	DepthBias = -20000
	SlopeScaleDepthBias = 2
}

RasterizerState NoCulling
{
	cullmode = none
}


Effect standard_usercolor
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "USER_COLOR" }
}
Effect standard_usercolorShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}
Effect standard_usercolor_winter
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "USER_COLOR" "APPLY_WINTER" }
}
Effect standard_usercolor_winterShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}


Effect standard_usercolor_alpha
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "USER_COLOR" }
}
Effect standard_usercolor_alphaShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

Effect standard_usercolor_coa
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "USER_COLOR" "COA" }
}
Effect standard_usercolor_coaShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}
Effect standard
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
}
Effect standardShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}
Effect standard_atlas
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" "APPLY_WINTER" }
}
Effect standard_atlasShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"		
	RasterizerState = ShadowRasterizerState
}
Effect standard_winter
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "APPLY_WINTER" }
}
Effect standard_winterShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}
Effect sine_flag_animation
{
	VertexShader = "VS_sine_animation"
	PixelShader = "PS_standard"
	#RasterizerState = NoCulling
	Defines = { "USER_COLOR" }
}
Effect sine_flag_animationShadow
{
	VertexShader = "VS_sine_animation_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}


Effect standard_alpha_blend
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_no_write"
}
Effect standard_alpha_blendShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	
	RasterizerState = ShadowRasterizerState
}

Effect standard_alpha_to_coverage
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
}
Effect standard_alpha_to_coverageShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	
	RasterizerState = ShadowRasterizerState
}
Effect standard_alpha_to_coverage_winter
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "APPLY_WINTER" }
}
Effect standard_alpha_to_coverage_winterShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"

	RasterizerState = ShadowRasterizerState
}



Effect snap_to_terrain
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "APPLY_WINTER" }
}
Effect snap_to_terrainShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
	RasterizerState = ShadowRasterizerState
}
Effect snap_to_terrain_alpha_to_coverage
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "APPLY_WINTER" }
}
Effect snap_to_terrain_alpha_to_coverageShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}
Effect snap_to_terrain_atlas
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "APPLY_WINTER" }
}
Effect snap_to_terrain_atlasShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"		
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}
Effect snap_to_terrain_atlas_usercolor
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "USER_COLOR" "APPLY_WINTER" }
}
Effect snap_to_terrain_atlas_usercolorShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"		
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}

Effect selection_marker
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_no_write"
	RasterizerState = SelectionRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "SELECTION_MARKER" }
}
Effect selection_markerShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
	RasterizerState = ShadowRasterizerState
}

Effect material_test
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "NORMAL_UV_SET Input.UV1" "DIFFUSE_UV_SET Input.UV1" }
}

#Map object shaders
Effect standard_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
}
Effect standardShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
}

Effect standard_alpha_to_coverage_mapobject
{
    VertexShader = "VS_mapobject"
    PixelShader = "PS_standard"
    BlendState = "alpha_to_coverage"
}
Effect standard_alpha_to_coverageShadow_mapobject
{
    VertexShader = "VS_jomini_mapobject_shadow"
    PixelShader = "PS_jomini_mapobject_shadow_alphablend"
    
    RasterizerState = ShadowRasterizerState
}
Effect standard_atlas_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" }
}
Effect standard_atlasShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"		
	RasterizerState = ShadowRasterizerState
}







Effect snap_to_terrain_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}
Effect snap_to_terrainShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
	RasterizerState = ShadowRasterizerState
}
Effect snap_to_terrain_alpha_to_coverage_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}
Effect snap_to_terrain_alpha_to_coverageShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}
Effect snap_to_terrain_atlas_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" }
}
Effect snap_to_terrain_atlasShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"		
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}
Effect snap_to_terrain_atlas_usercolor_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "USER_COLOR" }
}
Effect snap_to_terrain_atlas_usercolorShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"		
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}

# MOD(map-skybox)
Effect SKYX_sky
{
	VertexShader = "VS_standard"
	PixelShader = "SKYX_PS_sky"
}

Effect SKYX_sky_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "SKYX_PS_sky"
}

Effect SKYX_sky_selection_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "SKYX_PS_sky"
}
# END MOD


#EK2

Effect EK2_snap_to_terrain
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "APPLY_WINTER" "APPLY_TERRAIN_TEXTURE"}
}

Effect EK2_snap_to_terrain_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "APPLY_WINTER" "APPLY_TERRAIN_TEXTURE"}
}

#END-EK2


Effect court
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
}

Effect courtShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

