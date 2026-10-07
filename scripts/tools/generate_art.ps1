# Gatebreakers - geracao de arte via Gemini Image API (uso privado)
# Uso: powershell -File scripts/tools/generate_art.ps1 -Asset <nome> [-OutDir assets/units]
# A chave e lida da variavel de ambiente User (GOOGLE_API_KEY) e nunca gravada em arquivo.
param(
	[Parameter(Mandatory=$true)][string]$Asset,
	[string]$OutDir = "assets_gen",
	[string]$Aspect = ""
)
$ErrorActionPreference = "Stop"
$key = [Environment]::GetEnvironmentVariable("GOOGLE_API_KEY","User")
if (-not $key) { Write-Error "GOOGLE_API_KEY ausente (User)"; exit 1 }

$style = @(
	"Ilustracao 2D para jogo mobile, estilo anime/webtoon coreano, cel-shading suave com contorno fino,",
	"paleta escura e saturada (azul-noite, roxo sombra, ciano neon), sombras em roxo, brilho ciano nas bordas,",
	"personagem de corpo inteiro centralizado, vista frontal, pose neutra de combate, alta legibilidade de silhueta,",
	"SEM texto, sem moldura, sem marca d'agua, sem sombra projetada no chao.",
	"FUNDOS TOTALMENTE TRANSPARENTES: todo pixel que nao pertence ao personagem deve ficar alfa zero,",
	"recorte limpo nas bordas, sem halo."
) -join " "
$negative = "texto, letras, logotipo, moldura, watermark, fundo visivel, cenario, sombra no chao, varios personagens, corte de membros, anatomia deformada, estilo realista fotografico"

$prompts = @{
	"hunter_yoojinho" = "Jovem caçador rank D, cabelo castanho claro penteado para tras, sorriso confiante, jaqueta de moto azul-escura com detalhes prateados, espada curta de treino nas costas, luvas de couro, proporcoes realistas de heroi jovem de webtoon coreano";
	"hunter_songchiyul" = "Caçador veterano rank C, homem de meia-idade oriental, coque de cabelo preto com barba curta grisalha, dogi tradicional de kumdo azul-escuro com cinto preto, katana empunhada com duas maos, postura firme de espadachim, cicatriz discreta na bochecha";
	"hunter_leejoohee" = "Corpo INTEIRO da cabeça aos pés, os dois pés totalmente visíveis na borda inferior. Caçadora healer rank B, mulher jovem de cabelo castanho em rabo de cavalo baixo, uniforme branco e azul claro de squad medico com calça, cajado curto de cristal ciano brilhando, aura suave de cura verde-agua em volta das maos, expressao gentil e reservada, altura completa em pé";
	"hunter_woojinchul" = "Caçador inspetor rank A, homem de cabelo preto curto alinhado, terno preto impecavel sobre armadura leve de mana, oculos de armação, luvas pretas, aura de vigilancia azul discreta, postura de agente de seguranca";
	"monstro_goblin_corpo" = "Goblin rank E de masmorra, verde musgo, olhos vermelhos brilhando, tanga de couro tosco, adaga enferrujada na mao, corpo pequeno curvado e agressivo, escamas nos antebraços";
	"monstro_kasaka_corpo" = "Serpente monstro rank C chefe de masmorra, corpo azul-escura com pregas, presas venenosas douradas, olhos amarelos penetrantes, crista de escamas anil, pose de ataque erguida, escamas com brilho molhado";
	"monstro_gigante_corpo" = "Gigante de pedra rank S chefe, humanoid de pedra cinza-escura com runas roxas acesas nas juntas, ombros macicos, correntes quebradas pendendo dos pulsos, olhos de magma roxo, escala imponente de boss final";
}

$scenes = @{
	"hub_background" = "Cidade moderna noturna coreana ao pe de montanhas altas, portais dimensionais azul-violeta flutuando sobre as ruas, atmosfera de fantasia sombria, iluminacao dramatica, vista vertical 9:16 para tela inicial de RPG idle, SEM personagens, SEM texto, sem watermark, qualidade cinematica, sem caixas de interface";
}

if ($scenes.ContainsKey($Asset)) {
	$prompt = "Ilustracao 2D para jogo mobile, estilo anime/webtoon coreano, cel-shading suave, paleta escura e saturada (azul-noite, roxo sombra, ciano neon), sombras em roxo, brilho ciano nas bordas. Cenario: $($scenes[$Asset]). Negative: $negative"
} else {
	if (-not $prompts.ContainsKey($Asset)) { Write-Error "Asset desconhecido: $Asset"; exit 1 }
	$prompt = "$style. Personagem: $($prompts[$Asset]). Negative: $negative"
}
if ($Aspect) { $prompt += " Proporcao: $Aspect" }

$body = @{
	contents = @(@{ parts = @(@{ text = $prompt }) })
	generationConfig = @{ responseModalities = @("IMAGE") }
} | ConvertTo-Json -Depth 8
$bytes = [Text.Encoding]::UTF8.GetBytes($body)

$uri = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent"
$r = Invoke-RestMethod -Uri $uri -Method Post -Headers @{ "x-goog-api-key" = $key } -ContentType "application/json; charset=utf-8" -Body $bytes -TimeoutSec 120

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
$saved = 0
foreach ($part in $r.candidates[0].content.parts) {
	if ($part.inlineData) {
		$saved += 1
		$ext = @{ "image/png" = "png"; "image/jpeg" = "jpg" }[[string]$part.inlineData.mimeType]
		$out = Join-Path $OutDir ("{0}{1}.{2}" -f $Asset, ($(if ($saved -gt 1) { "_v$saved" } else { "" })), $ext)
		[IO.File]::WriteAllBytes($out, [Convert]::FromBase64String($part.inlineData.data))
		Write-Output "OK: $out ($($part.inlineData.mimeType))"
	}
}
if ($saved -eq 0) { Write-Output "SEM IMAGEM NA RESPOSTA: $($r.candidates[0].content | ConvertTo-Json -Depth 5)" }
