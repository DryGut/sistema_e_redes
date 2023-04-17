Add-Type -AssemblyName PresentationFramework
$computer = $env:COMPUTERNAME

function Get-Permission{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$path
	)
	$fdpath = (Get-Acl $path).access | Select-Object IdentityReference, AccessControlType, FileSystemRights
	$fdpath
}

function Get-UserInfo{
	[CmdletBinding()]
	$userinfo = Get-WmiObject -Class Win32_ComputerSystem -Property UserName
	$userinfo.UserName
}
function Get-ComputerBios{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$computer
	)
	$computerbios = Get-WmiObject -Class Win32_Bios -ComputerName $computer | 
	Select-Object -Property PSComputerName, Status, BIOSVerison, Name, __SERVER
	$computerbios
}

function Get-InfoSistema{
	[CmdletBinding()]
	$OSinfo = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property Caption, Version, OSArchitecture
	$Systeminfo = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property Manufacturer, BootupState, DNSHostName, Model, Roles
	$processador = Get-WmiObject -Class Win32_Processor
	$computerinfo = @{'Caption'=$Osinfo.Caption; 'Version'=$OSinfo.Version; 'OsArchitecture'=$OSinfo.OSArchitecture;
						'Manufacturer'=$Systeminfo.Manufacturer; 'BootupState'=$Systeminfo.BootupState; 'DNSHostName'=$Systeminfo.DNSHostName;
						'Model'=$Systeminfo.Model; 'Roles'=$Systeminfo.Roles; 'Caption1'=$processador.Caption; 'Name1'=$processador.Name}
	$computerinfo
}

function Get-InfoRedes{
	[CmdletBinding()]
	$networkinfo = Get-NetAdapter | Select-Object -Property Name, InterfaceDescription, Status, MacAddress
	$networkinfo
}

function Get-InfoIP{
	[CmdletBinding()]
	$IPinfo = Get-NetIPConfiguration | Where-Object {$_.NetAdapter.Status -ne 'Disconnected'} | 
	Select-Object -Property InterfaceAlias, InterfaceDescription, IPv4Address
	$ip = Get-NetIPAddress | Select-Object -Property IPAddress, InterfaceAlias | Where-Object {$_.InterfaceAlias -eq $IPinfo.interfacealias}
	$novoFormato = @{'IPAddress'=$ip.IPAddress; 'InterfaceAlias'=$ip.InterfaceAlias; 'InterfaceDescription'=$ipinfo.InterfaceDescription}
	$novoFormato
}

function Get-SystemUpdate{
	[CmdletBinding()]
	$update = Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName $computer | 
	Select-Object Description, HotFixID, InstalledOn
	$update
}

$xamlFile = @"
<Window x:Class="ControleDeSistema.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:ControleDeSistema"
        mc:Ignorable="d"
        Title="Sistema de Mapeamento" Height="450" Width="800">
    <Grid>
        <TabControl>
            <TabItem Header="Mapeamento da BIOS">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Descricao da BIOS:" HorizontalAlignment="Center" Margin="10,31,0,0" VerticalAlignment="Top"/>
                    <Button Name="btnBios" Content="Consulta" HorizontalAlignment="Right" Margin="0,340,40,0" VerticalAlignment="Top"/>
                    <TextBox Name="txtBiosResults" HorizontalAlignment="Left" Margin="24,73,0,0"  Text="" VerticalAlignment="Top" Width="736" Height="262"/>
                </Grid>
            </TabItem>
            <TabItem Header="Mapeamento do Sistema">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Detalhes do Sistema:" HorizontalAlignment="Center" Margin="10,31,0,0" VerticalAlignment="Top" />
                    <Button Name="btnSystem" Content="Consulta" HorizontalAlignment="Right" Margin="0,340,40,0" VerticalAlignment="Top"  />
                    <TextBox Name="txtSystemResults" HorizontalAlignment="Left" Margin="24,73,0,0"  Text="" VerticalAlignment="Top" Width="736" Height="262" />
                </Grid>
            </TabItem>
            <TabItem Header="Mapeamento da Rede">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Adaptadores de Rede" HorizontalAlignment="Center" Margin="10,31,0,0" VerticalAlignment="Top"/>
                    <Button Name="btnNetwork" Content="Consulta" HorizontalAlignment="Right" Margin="0,340,40,0" VerticalAlignment="Top"/>
                    <TextBox Name="txtNetworkResults" HorizontalAlignment="Left" Margin="24,73,0,0" Text="" VerticalAlignment="Top" Width="736" Height="262"/>
                </Grid>
            </TabItem>
            <TabItem Header="Consultar IP">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Identificando IP" HorizontalAlignment="Center" Margin="10,31,0,0" VerticalAlignment="Top"/>
                    <Button Name="btnIP" Content="Consulta" HorizontalAlignment="Right" Margin="0,340,40,0" VerticalAlignment="Top"/>
                    <TextBox Name="txtIPResults" HorizontalAlignment="Left" Margin="24,73,0,0" Text="" VerticalAlignment="Top" Width="736" Height="262"/>
                </Grid>
            </TabItem>
            <TabItem Header="Enumerando Permissoes">
                <Grid Background="#FFE5E5E5">
					<Label Name="lbFound" Content="" HorizontalAlignment="Center" Margin="0,10,0,0" VerticalAlignment="Bottom" />
                    <Button Name="btnPerm" Content="Consulta" HorizontalAlignment="Right" Margin="0,340,40,0" VerticalAlignment="Top"  />
					<Label Name="lbError" Content="" HorizontalAlignment="Center" Foreground="red" Margin="550,10,0,0" VerticalAlignment="Top"/>
                    <Label Content="Insira o Caminho do Arquivo ou Diretorio:" HorizontalAlignment="Center" Margin="10,32,0,0" VerticalAlignment="Top"/>
                    <TextBox Name="txtPerm" Text="" Margin="10,36,35,0" HorizontalAlignment="Right" VerticalAlignment="Top" Width="190" Height="20"/>
                    <TextBox Name="txtPermResults" HorizontalAlignment="Left" Margin="24,73,0,0"  Text="" VerticalAlignment="Top" Width="736" Height="262" />
                </Grid>
            </TabItem>
            <TabItem Header="Enumerando Usuarios">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Usuarios Cadastrados no Sistema:" HorizontalAlignment="Center" Margin="10,31,0,0" VerticalAlignment="Top" />
                    <Button Name="btnUsers" Content="Consulta" HorizontalAlignment="Right" Margin="0,340,40,0" VerticalAlignment="Top"  />
                    <TextBox Name="txtUsersResults" HorizontalAlignment="Left" Margin="24,73,0,0"  Text="" VerticalAlignment="Top" Width="736" Height="262" />
                </Grid>
            </TabItem>
            <TabItem Header="Atualizacoes do Sistema">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Atualizacoes Feitas:" HorizontalAlignment="Center" Margin="10,31,0,0" VerticalAlignment="Top" />
                    <Button Name="btnUpdate" Content="Consulta" HorizontalAlignment="Right" Margin="0,340,40,0" VerticalAlignment="Top"  />
                    <TextBox Name="txtUpdateResults" HorizontalAlignment="Left" Margin="24,73,0,0"  Text="" VerticalAlignment="Top" Width="736" Height="262" />
                </Grid>
            </TabItem>
        </TabControl>
    </Grid>
</Window>
"@


$inputXML = $xamlFile -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML


$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try{
	$window = [Windows.Markup.XamlReader]::Load($reader)
}catch{
	Write-Warning $_.Exception
	throw
}



$xaml.SelectNodes("//*[@Name]") | ForEach-Object{
	try{
		Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
	}catch{
		throw
	}
}

$var_btnBios.Add_Click({
	$var_txtBiosResults.Text = ''
	if($result = Get-ComputerBios -Computer $computer){
		foreach($item in $result){
			$var_txtBiosResults.Text = $var_txtBiosResults.Text + "PSComputerName:`t$($item.PSComputerName)`n"
			$var_txtBiosResults.Text = $var_txtBiosResults.Text + "Status:`t		$($item.Status)`n"
			$var_txtBiosResults.Text = $var_txtBiosResults.Text + "BIOSVersion:`t	$($item.BIOSVersion)`n"
			$var_txtBiosResults.Text = $var_txtBiosResults.Text + "Name:`t		$($item.Name)`n"
			$var_txtBiosResults.Text = $var_txtBiosResults.Text + "SERVER:`t		$($item.__SERVER)`n"
		}
	}
})
$var_btnSystem.Add_CLick({
	$var_txtSystemResults.Text = ''
	if($result1 = Get-InfoSistema){
		foreach($item1 in $result1){
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Nome do SO:`t	$($item1.Caption)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Versao do SO:`t	$($item1.Version)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Arquitetura do SO:`t$($item1.OsArchitecture)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Fabricante da BIOS:`t$($item1.Manufacturer)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Estado de Inicializacao:`t$($item1.BootupState)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Nome do Host de DNS:`t$($item1.DNSHostName)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Modelo da Maquina:`t$($item1.Model)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Funcoes da Maquina:`t$($item1.Roles)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Processador:`t 	$($item1.Name1)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Modelo:`t 		$($item1.Caption1)`n"
		}
	}
})
$var_btnNetwork.Add_Click({
	$var_txtNetworkResults.Text = ''
	if($result2 = Get-InfoRedes){
		foreach($item2 in $result2){
			$var_txtNetworkResults.Text = $var_txtNetworkResults.Text + "Nome:`t			$($item2.Name)`n"
			$var_txtNetworkResults.Text = $var_txtNetworkResults.Text + "Descricao da Interface:`t	$($item2.InterfaceDescription)`n"
			$var_txtNetworkResults.Text = $var_txtNetworkResults.Text + "Status:`t			$($item2.Status)`n"
			$var_txtNetworkResults.Text = $var_txtNetworkResults.Text + "Endereco MAC:`t		$($item2.MacAddress)`n`n"
		}
	}
})
$var_btnIP.Add_Click({
	$var_txtIPResults.Text = ''
	if($result3 = Get-InfoIP){
		foreach($item3 in $result3){
			$var_txtIPResults.Text = $var_txtIPResults.Text + "Nome da Interface:`t		$($item3.InterfaceAlias[0])`n"
			$var_txtIPResults.Text = $var_txtIPResults.Text + "Descricao da Interface:`t		$($item3.InterfaceDescription)`n"
			$var_txtIPResults.Text = $var_txtIPResults.Text + "Endereco IPv4:`t			$($item3.IPAddress[1])`n"
			$var_txtIPResults.Text = $var_txtIPResults.Text + "Endereco IPv6:`t 			$($item3.IPAddress[0])`n"
		}
	}
})

$var_btnPerm.Add_Click({
	$var_txtPermResults.Text = ''
	$var_lbError.Content = ''
	$var_lbFound.Content = ''
	if($result4 = Get-Permission -Path $var_txtPerm.Text){
		foreach($item4 in $result4){
			$var_txtPermResults.Text = $var_txtPermResults.Text + "ID de Referencia:`t 	 $($item4.IdentityReference)`n"
			$var_txtPermResults.Text = $var_txtPermResults.Text + "Tipo de Acesso:`t 	 $($item4.AccessControlType)`n"
			$var_txtPermResults.Text = $var_txtPermResults.Text + "Permissoes ao Arquivo:`t $($item4.FileSystemRights)`n`n"
			$var_lbFound.Content = "Permissoes Encontradas"
		}
	} else {
		$var_lbError.Content = "Insira um Caminho Valido"
	}
})

$var_btnUsers.Add_Click({
	$var_txtUsersResults.Text = ''
	if($result5 = Get-WmiObject -Class Win32_UserAccount){
		$var_txtUsersResults.Text = $var_txtUsersResults.Text + "Usuario Logado:`t 	 $(Get-UserInfo)`n`n"
		foreach($item5 in $result5){
			$var_txtUsersResults.Text = $var_txtUsersResults.Text + "Tipo da Conta:`t 	 $($item5.AccountType)`n"
			$var_txtUsersResults.Text = $var_txtUsersResults.Text + "Dominio e Conta:`t 	 $($item5.Caption)`n"
			$var_txtUsersResults.Text = $var_txtUsersResults.Text + "Nome Completo:`t 	 $($item5.FullName)`n"
			$var_txtUsersResults.Text = $var_txtUsersResults.Text + "SID:`t 	 	 $($item5.SID)`n`n"
		}
	}
})

$var_btnUpdate.Add_Click({
	$var_txtUpdateResults.Text = ''
	if($result6 = Get-SystemUpdate){
		foreach($item6 in $result6){
			$var_txtUpdateResults.Text = $var_txtUpdateResults.Text + "Descricao:`t 	 $($item6.Description)`n"
			$var_txtUpdateResults.Text = $var_txtUpdateResults.Text + "ID da Atualizacao:`t 	 $($item6.HotFixID)`n"
			$var_txtUpdateResults.Text = $var_txtUpdateResults.Text + "Instalado em:`t 	 $($item6.InstalledOn)`n`n"
		}
	}
})
$Null = $window.ShowDialog()