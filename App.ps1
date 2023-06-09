using assembly System.Windows.Forms
using namespace System.Windows.Forms


$form = [Form]@{
    Text = 'System and Networks'
    Size = '669,527'
    MainMenuStrip = $MS_Main
    AutoSize = $false
    MaximizeBox = $false
    FormBorderStyle = 'FixedSingle'
    #Icon = 'C:\Users\renato\EstudoPS\pwshOO\iconepwsh.ico'
}

$label = [Label]@{
    Text = 'PESys - Personal Enumeration System'
    Font = 'CaskaydiaCove NFM, 14pt'
    Location = '20,35'
    Size = '405,24'
    AutoSize = $true
}
$label2 = [Label]@{
    Text = 'Powered by: PowerShell'
    Font = 'Cascadia Code, 8.25pt, style=Italic'
    Location = '270,62'
    Size = '139,15'
    ForeColor = '195,0,0'
    AutoSize = $true
}
$label3 = [Label]@{
    Text = ''
    Font = 'CaskaydiaCove NFM, 10pt'
    Location = '24,80'
    Size = '139,15'
    AutoSize = $true
}

$label4 = [Label]@{
    Text = 'Path:'
    Location = '24,80'
    Size = '32,13'
    Margin = '3,0,3,0'
}

$permInput = [TextBox]@{
    Text = ''
    Location = '62,77'
    Margin = '3,3,3,3'
    Size = '130,20'
}

$text = [RichTextBox]@{
    Text = ''
    Location = '12,103'
    Margin = '3,3,3,3'
    Size = '413,344'
}

$button = [Button]@{
    Text = ''
    Margin = '3,3,3,3'
    Location = '154,453'
    Size = '75,23'
}

$link = [LinkLabel]@{
    Text = 'github.com/DryGut'
    Location = '489,321'
    Size = '120,13'
    Margin = '3,0,3,0'
    Font = 'Microsoft Sans Serif, 9pt'
    LinkBehavior = 'HoverUnderLine'
}
$permButton = [Button]@{
    Text = ''
    Margin = '3,3,3,3'
    Location = '154,453'
    Size = '75,23'
}

#$file = (Get-Item 'C:\Users\renato\Downloads\renatologo1.png')
$logo = [PictureBox]@{
    Location = '444,103'
    Size = '197,201'
    Margin = '3,3,3,3'
    #Image = [System.Drawing.Image]::FromFile($file)
}

$erro = [Label]@{
    Text = 'Empty or Invalid Field'
    Font = 'Microsoft Sans Serif, 8.25pt, style=Bold'
    ForeColor = '192,0,0'
    Location = '259,458'
    Margin = '3,0,3,0'
    Size = '147,13'
}

# Criando o Menu de Opções
$MS_Main = [MenuStrip]@{
    Location = '0,0'
    Name = 'MS_Main'
    Size = '354,24'
    TabIndex = '0'
    Text = 'menuStrip1'
    BackColor = 'MenuHighLight'
}

$sistemaOpcoes = [ToolStripMenuItem]@{
    Name = 'sistemaOpcoesToolStripMenuItem'
    Size = '35,20'
    Text = '&System'
}
$networkOpcoes = [ToolStripMenuItem]@{
    Name = 'networkOpcoesToolStripMenuItem'
    Size = '35,20'
    Text = '&Networks'
}

$userOpcoes = [ToolStripMenuItem]@{
    Name = 'userOpcoesToolStripMenuItem'
    Size = '35,20'
    Text = '&Users'
}

$sysScan = [ToolStripMenuItem]@{
    Name = 'sysScanToolStripMenuItem'
    Size = '35,20'
    Text = '&SysScan'
}

$permScan = [ToolStripMenuItem]@{
    Name = 'permScanToolStripMenuItem'
    Size = '35,20'
    Text = '&PermissionScan'
}

$userScan = [ToolStripMenuItem]@{
    Name = 'userScanToolStripMenuItem'
    Size = '35,20'
    Text = '&userScan'
}

$biosScan = [ToolStripMenuItem]@{
    Name = 'biosScanToolStripMenuItem'
    Size = '35,20'
    Text = '&BIOSScan'
}

$updateScan = [ToolStripMenuItem]@{
    Name = 'updateScanToolStripMenuItem'
    Size = '35,20'
    Text = '&UpdateScan'
}

$networkScan = [ToolStripMenuItem]@{
    Name = 'networkScanToolStripMenuItem'
    Size = '35,20'
    Text = '&NetworkScans'
}

$ipScan = [ToolStripMenuItem]@{
    Name = 'ipScanToolStripMenuItem'
    Size = '35,20'
    Text = '&IPScan'
}


function Get-InfoSistema{
	[CmdletBinding()]
	$OSinfo = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property Caption, Version, OSArchitecture, SerialNumber
	$Systeminfo = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property Manufacturer, BootupState, DNSHostName, Model, Roles, TotalPhysicalMemory
	$processador = Get-WmiObject -Class Win32_Processor
    $disco = Get-WmiObject -Class Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object DeviceID, DriveType, FreeSpace, Size
	$computerinfo = @{'Caption'=$Osinfo.Caption; 'Version'=$OSinfo.Version; 'OsArchitecture'=$OSinfo.OSArchitecture;
						'Manufacturer'=$Systeminfo.Manufacturer; 'BootupState'=$Systeminfo.BootupState; 'DNSHostName'=$Systeminfo.DNSHostName;
						'Model'=$Systeminfo.Model; 'Roles'=$Systeminfo.Roles; 'Caption1'=$processador.Caption; 'Name1'=$processador.Name; 
                        'Memoria'=$Systeminfo.TotalPhysicalMemory; 'SerialNumber'=$OSinfo.SerialNumber; 'Device'=$disco.DeviceID; 'DriveType'=$disco.DriveType;
                        'FreeSpace'=$disco.FreeSpace; 'Size'=$disco.Size}
	$computerinfo
}

function Onclick_sysScan($botao, $e){
    RemoveBotao
    montaFormulario 'System Mapping' 'Search'
    $form.Controls.Add($button)
    $button.Add_Click{
        $text.Text = ''
        $result = Get-InfoSistema
        foreach($item in $result){
            $text.Text = $text.Text + "OS Name:`t`t$($item.Caption)`n"
			$text.Text = $text.Text + "Os Version:`t`t$($item.Version)`n"
            $text.Text = $text.Text + "Serial Number:`t`t$($item.SerialNumber)`n"
			$text.Text = $text.Text + "Os Architecture:`t`t$($item.OsArchitecture)`n"
            $text.Text = $text.Text + "Physical Memory:`t`t$([math]::round($item.Memoria / 1GB)) GB`n"
            $text.Text = $text.Text + "Device ID:`t`t$($item.Device)`n"
            $text.Text = $text.Text + "Drive Type:`t`t$($item.DriveType)`n"
            $text.Text = $text.Text + "Storage:`t`t`t$([math]::round($item.Size / 1GB)) GB`n"
            $text.Text = $text.Text + "Free Space:`t`t$([math]::round($item.FreeSpace / 1GB)) GB`n"
			$text.Text = $text.Text + "BIOS Manufacture:`t`t$($item.Manufacturer)`n"
			$text.Text = $text.Text + "Boot Up State:`t`t$($item.BootupState)`n"
			$text.Text = $text.Text + "DNS Host Name:`t`t$($item.DNSHostName)`n"
			$text.Text = $text.Text + "Model:`t`t`t$($item.Model)`n"
			$text.Text = $text.Text + "Roles:`t`t`t$($item.Roles)`n"
			$text.Text = $text.Text + "Processors:`t`t$($item.Name1)`n"
			$text.Text = $text.Text + "Model:`t`t`t$($item.Caption1)`n"
        }
    }
    limpandoForm
}

function Get-ComputerBios{
	[CmdletBinding()]
	$computerbios = Get-WmiObject -Class Win32_Bios | 
	Select-Object -Property PSComputerName, Status, BIOSVerison, Name, __SERVER
	$computerbios
}

function OnClick_biosScan($botao, $e){
    RemoveBotao
    montaFormulario 'BIOS Mapping' 'Search'
    $form.Controls.Add($button)
    $button.Add_Click{
        $text.Text = ''
        $result1 = Get-ComputerBios
        foreach($item1 in $result1){
            $text.Text = $text.Text + "PSComputerName:`t`t$($item1.PSComputerName)`n"
			$text.Text = $text.Text + "Status:`t`t`t$($item1.Status)`n"
			$text.Text = $text.Text + "BIOSVersion:`t`t$($item1.BIOSVersion)`n"
			$text.Text = $text.Text + "Name:`t`t`t$($item1.Name)`n"
			$text.Text = $text.Text + "SERVER:`t`t`t$($item1.__SERVER)`n"
        }
    }
    limpandoForm
}
function Get-UserInfo{
	[CmdletBinding()]
	$userinfo = Get-WmiObject -Class Win32_ComputerSystem -Property UserName
	$userinfo.UserName
}

function OnClick_userScan($botao, $e){
    RemoveBotao
    montaFormulario 'User Enumeration' 'Search'
    $form.Controls.Add($button)
    $button.Add_Click{
        $text.Text = ''
        if($result2 = Get-WmiObject -Class Win32_UserAccount){
            $text.Text = $text.Text + "Logged User:`t`t$(Get-UserInfo)`n`n"
            foreach($item2 in $result2){
                $text.Text = $text.Text + "Account Type:`t`t$($item2.AccountType)`n"
                $text.Text = $text.Text + "Domain/Account:`t`t$($item2.Caption)`n"
                $text.Text = $text.Text + "Full Name:`t`t$($item2.FullName)`n"
                $text.Text = $text.Text + "SID:`t`t`t$($item2.SID)`n`n"
            }
        }
        $permInput.Text = ''
    }
    limpandoForm
}

function Get-Permission{
	[CmdletBinding()]
	param(
		[string]$path
	)
	$fdpath = (Get-Acl $path).access | Select-Object IdentityReference, AccessControlType, FileSystemRights
	$fdpath
}

function OnClick_permScan($botao, $e){
    RemoveBotao
    $form.Controls.Add($permButton)
    $form.Controls.Add($permInput)
    $permButton.Text = 'Permissions'
    $permButton.Add_Click{
        $text.Text = ''
        if($result3 = Get-Permission -Path $permInput.Text){
            foreach($item3 in $result3){
                $text.Text = $text.Text + "Reference ID:`t`t$($item3.IdentityReference)`n"
                $text.Text = $text.Text + "Access Control Type:`t$($item3.AccessControlType)`n"
                $text.Text = $text.Text + "File System Rights:`t`t$($item3.FileSystemRights)`n`n"
                $form.Controls.Remove($erro)
            } 
        } else {
            $form.Controls.Add($erro)
        }
    }
    $form.Controls.Remove($label3)
    $form.Controls.Add($label4)
}

function OnClick_networkScan($botao, $e){
    RemoveBotao
    montaFormulario 'Network Adapters' 'Search'
    $form.Controls.Add($button)
    $button.Add_Click{
        $text.Text = ''
        $result4 =  Get-NetAdapter | Select-Object -Property Name, InterfaceDescription, Status, MacAddress
        foreach($item4 in $result4){
            $text.Text = $text.Text + "Name:`t`t`t$($item4.Name)`n"
            $text.Text = $text.Text + "Interface Description:`t$($item4.InterfaceDescription)`n"
            $text.Text = $text.Text + "Status:`t`t`t$($item4.Status)`n"
            $text.Text = $text.Text + "MacAddress:`t`t$($item4.MacAddress)`n`n"
        }
    }
    limpandoForm
}

function Get-InfoIP{
	[CmdletBinding()]
	$IPinfo = Get-NetIPConfiguration | Where-Object {$_.NetAdapter.Status -ne 'Disconnected'} | 
	Select-Object -Property InterfaceAlias, InterfaceDescription, IPv4Address
	$ip = Get-NetIPAddress | Select-Object -Property IPAddress, InterfaceAlias | Where-Object {$_.InterfaceAlias -eq $IPinfo.interfacealias}
	$novoFormato = @{'IPAddress'=$ip.IPAddress; 'InterfaceAlias'=$ip.InterfaceAlias; 'InterfaceDescription'=$ipinfo.InterfaceDescription}
	$novoFormato
}

function OnCLick_ipScan($botao, $e){
    RemoveBotao
    montaFormulario 'Network Mapping' 'Search'
    $form.Controls.Add($button)
    $button.Add_Click{
        $text.Text = ''
        $result5 = Get-InfoIP
        foreach($item5 in $result5){
            $text.Text = $text.Text + "Interface Alias:`t`t$($item5.InterfaceAlias[0])`n"
			$text.Text = $text.Text + "Interface Description:`t$($item5.InterfaceDescription)`n"
			$text.Text = $text.Text + "IPv4 Address:`t`t$($item5.IPAddress[1])`n"
			$text.Text = $text.Text + "IPv6 Address:`t`t$($item5.IPAddress[0])`n"
        }
    }
    limpandoForm
}

function Get-SystemUpdate{
	[CmdletBinding()]
	$update = Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName $env:COMPUTERNAME | 
	Select-Object Description, HotFixID
	$update
}

function OnClick_updateScan($botao, $e){
    RemoveBotao
    montaFormulario 'Update Mapping' 'Search'
    $form.Controls.Add($button)
    $button.Add_CLick{
        $text.Text = ''
        $result6 = Get-SystemUpdate
        foreach($item6 in $result6){
            $text.Text = $text.Text + "Description:`t$($item6.Description)`n"
			$text.Text = $text.Text + "HotFix ID:`t`t$($item6.HotFixID)`n`n"
        }
    }
    limpandoForm
}

function RemoveBotao{
    if($form.Controls.Contains($button)){
        $form.Controls.Remove($button)
        $text.Text=''
    }
    $form.Controls.Add($text)
    $form.Controls.Add($label3)
}

function montaFormulario([string]$txtlabel, [string]$txtbtn){
    $label3.Text = $txtlabel
    $button.Text = $txtbtn
}

function limpandoForm{
    $form.Controls.Remove($permButton)
    $form.Controls.Remove($label4)
    $form.Controls.Remove($permInput)
    $form.Controls.Remove($erro)
}

$MS_Main.Items.AddRange(@(
    $sistemaOpcoes, $networkOpcoes, $userOpcoes))

$sistemaOpcoes.DropDownItems.AddRange(@($sysScan, $biosScan, $updateScan))
$sysScan.Add_Click({Onclick_sysScan $sysScan $EventArgs})
$biosScan.Add_CLick({OnClick_biosScan $biosScan $EventArgs})
$updateScan.Add_CLick({OnClick_updateScan $updateScan $EventArgs})

$networkOpcoes.DropDownItems.AddRange(@($networkScan, $ipScan))
$networkScan.Add_Click({OnClick_networkScan $networkScan $EventArgs})
$ipScan.Add_Click({OnCLick_ipScan $ipScan $EventArgs})

$userOpcoes.DropDownItems.AddRange(@($userScan, $permScan))
$userScan.Add_Click({OnClick_userScan $userScan $EventArgs})
$permScan.Add_Click({OnClick_permScan $permScan $EventArgs})

$link.Add_Click({[system.Diagnostics.Process]::start("http://github.com/DryGut")})

$form.Controls.Add($MS_Main)
$form.Controls.Add($label)
$form.Controls.Add($label2)
$form.Controls.Add($link)
$form.Controls.Add($logo)
$form.ShowDialog()