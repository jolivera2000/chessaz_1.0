param(
	$outputDirectory = (property outputDirectory "artifacts"),
	$configuration = (property configuration "Release")
)

$absoluteOutputDirectory = "$((Get-Location).Path)\$outputDirectory"
$projects = Get-SolutionProjects

Task Clean {
	if((Test-Path $absoluteOutputDirectory)){
		Remove-Item "$absoluteOutputDirectory" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
	}
	New-Item $absoluteOutputDirectory -ItemType Directory | Out-Null

	$projects |
		ForEach-Object {
			Remove-Item "$($_.Directory)\bin" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
			Remove-Item "$($_.Directory)\obj" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
		}
}

Task Compile{
	use "15.0" MSBuild
	$projects |
		ForEach-Object{
				$webOutDir = "$absoluteOutputDirectory\$($_.Name)"
				$outDir = "$absoluteOutputDirectory\$($_.Name)\bin"


			if($_.isWebProject){

				
				exec {MSBuild $($_.Path) /p:Configuration=$configuration /p:OutDir=$outDir /p:WebProjectOutputDir=$webOutDir `
										 /nologo /p:DebugType=None /p:Platform=AnyCpu /verbosity:quiet}

			}
			else{
				Write-Host "No Web Project"
				
				exec {MSBuild $($_.Path) /p:Configuration=$configuration /p:OutDir=$outDir `
										 /nologo /p:DebugType=None /p:Platform=AnyCpu /verbosity:quiet}
				
			}
		}
}

Task Pack{
	$projects |
		ForEach-Object {
			$octopusToolsPath = Get-PackagePath "OctopusTools" $($_.Directory)
			if($octopusToolsPath -eq $null){
				return
			}

			$version = "1.1.1.1"
			exec { & $octopusToolsPath\tools\Octo.exe pack `
													  --basePath=$absoluteOutputDirectory\$($_.Name) `
													  --outFolder=$absoluteOutputDirectory --id=$($_.Name) `
													  --overrite `
													  --version=$version
			}
		}
}