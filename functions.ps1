function Get-SolutionProjects
{
	Add-Type -Path (${env:ProgramFiles(x86)} + '\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\Microsoft.Build.dll')

	$solutionFile = (Get-ChildItem('*.sln')).FullName | Select -First 1
	$solution = [Microsoft.Build.Construction.SolutionFile] $solutionFile

	return $solution.ProjectsInOrder | 
	    Where-Object {$_.ProjectType -eq 'KnownToBeMSBuildFormat'} | 
		ForEach-Object {
		$isWebProject = (Select-String -pattern "<UserSecretsId>.+</UserSecretsId>" -path $_.AbsolutePath) -ne $null
		@{
			Path = $_.AbsolutePath;
			Name = $_.ProjectName;
			Directory = "$(Split-Path -Path $_.AbsolutePath -Resolve)";
			IsWebProject = $isWebProject
		}
	}

}

function Get-PackagePath($packageId, $projectPath)
{
	if (!(Test-Path "$projectPath\appsettings.json")){
		trown "Could not find appsettings.json file at $project"
	}

	[xml]$packagesXml = Get-Content "$projectPath\obj\project.assets.json"
	$package = $packagesXml.packages.package | Where { $_id -eq $packageId }
	if (!$package){
		return $null
	}
	return "packages\$($package.id).$($package.version)"
}