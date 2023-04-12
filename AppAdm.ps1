Add-Type -AssemblyName PresentationFramework
$computer = $env:COMPUTERNAME

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
	$computerinfo = Get-ComputerInfo | 
	Select-Object -Property OsName, OsType, OsVersion, OsArchitecture, 
	BiosManufacturer, CsBootupState, CsDNSHostName, CsModel, CsName, 
	CsRoles, CsSystemFamily, CsSystemType, CsUserName, LogonServer
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
            <TabItem Header="Mapeamento da BIOS" Foreground="#33FF33" Background="#000000">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Descricao da BIOS:" HorizontalAlignment="Center" Margin="10,31,0,0" VerticalAlignment="Top"/>
                    <Button Name="btnBios" Content="Consulta" HorizontalAlignment="Right" Margin="0,340,40,0" VerticalAlignment="Top"/>
                    <TextBox Name="txtBiosResults" HorizontalAlignment="Left" Margin="24,73,0,0"  Text="" VerticalAlignment="Top" Width="736" Height="262"/>
                </Grid>
            </TabItem>
            <TabItem Header="Mapeamento do Sistema" Foreground="#FFFF00" Background="#000000">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Detalhes do Sistema:" HorizontalAlignment="Center" Margin="10,31,0,0" VerticalAlignment="Top" />
                    <Button Name="btnSystem" Content="Consulta" HorizontalAlignment="Right" Margin="0,340,40,0" VerticalAlignment="Top"  />
                    <TextBox Name="txtSystemResults" HorizontalAlignment="Left" Margin="24,73,0,0"  Text="" VerticalAlignment="Top" Width="736" Height="262" />
                </Grid>
            </TabItem>
            <TabItem Header="Mapeamento da Rede" Foreground="#CC0000" Background="#000000">
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
        </TabControl>
    </Grid>
</Window>
"@

#criando a janela
#$inputXML = Get-Content $xamlFile -Raw
$inputXML = $xamlFile -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML

#lendo o arquivo XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try{
	$window = [Windows.Markup.XamlReader]::Load($reader)
}catch{
	Write-Warning $_.Exception
	throw
}

# criando as variaveis baseado no controle de formaluraio
# seu formato será 'var_<control name>'

$xaml.SelectNodes("//*[@Name]") | ForEach-Object{
	#"trying item $($_.Name)"
	try{
		Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
	}catch{
		throw
	}
}
#Get-Variable var_*
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
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Nome do SO:`t	$($item1.OsName)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Tipo do SO:`t	$($item1.OsType)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Versao do SO:`t	$($item1.OsVersion)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Arquitetura do SO:`t$($item1.OsArchitecture)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Fabricante da BIOS:`t$($item1.BiosManufacturer)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Estado de Inicializacao:`t$($item1.CsBootupState)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Nome do Host de DNS:`t$($item1.CsDNSHostName)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Modelo da Maquina:`t$($item1.CsModel)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Nome da Maquina:`t$($item1.CsName)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Funcoes da Maquina:`t$($item1.CsRoles)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Sistema da Maquina:`t$($item1.CsSystemFamily)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Tipo do Sistema:`t	$($item1.CsSystemType)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Nome do Usuario:`t$($item1.CsUserName)`n"
			$var_txtSystemResults.Text = $var_txtSystemResults.Text + "Estacao Logada:`t	$($item1.LogonServer)`n"
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
$Null = $window.ShowDialog()