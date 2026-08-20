page 50200 "Environment Inspector"
{
    PageType = Card;
    Caption = 'Environment Inspector';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(BusinessCentral)
            {
                Caption = 'Business Central';

                field(ApplicationVersion; ApplicationVersion)
                {
                    ApplicationArea = All;
                    Caption = 'Application Version';
                    Editable = false;
                    ToolTip = 'Specifies the installed version of the Microsoft Base Application.';
                }

                field(EnvironmentName; EnvironmentName)
                {
                    ApplicationArea = All;
                    Caption = 'Environment Name';
                    Editable = false;
                }

                field(DeploymentType; DeploymentType)
                {
                    ApplicationArea = All;
                    Caption = 'Deployment Type';
                    Editable = false;
                }

                field(EnvironmentType; EnvironmentType)
                {
                    ApplicationArea = All;
                    Caption = 'Environment Type';
                    Editable = false;
                }

                field(ApplicationFamily; ApplicationFamily)
                {
                    ApplicationArea = All;
                    Caption = 'Application Family';
                    Editable = false;
                }

                field(CurrentCompany; CurrentCompany)
                {
                    ApplicationArea = All;
                    Caption = 'Company';
                    Editable = false;
                }

                field(CurrentUser; CurrentUser)
                {
                    ApplicationArea = All;
                    Caption = 'User';
                    Editable = false;
                }
            }

            group(ServiceTier)
            {
                Caption = 'Business Central Service Tier';

                field(ServerName; ServerName)
                {
                    ApplicationArea = All;
                    Caption = 'Server Name';
                    Editable = false;
                }

                field(OSVersion; OSVersion)
                {
                    ApplicationArea = All;
                    Caption = 'Operating System';
                    Editable = false;
                }

                field(CPUModel; CPUModel)
                {
                    ApplicationArea = All;
                    Caption = 'CPU';
                    Editable = false;
                }

                field(ProcessorCount; ProcessorCount)
                {
                    ApplicationArea = All;
                    Caption = 'Logical Processors';
                    Editable = false;
                }

                field(TotalRAM; TotalRAM)
                {
                    ApplicationArea = All;
                    Caption = 'Total RAM';
                    Editable = false;
                }

                field(Is64BitOS; Is64BitOS)
                {
                    ApplicationArea = All;
                    Caption = '64-bit OS';
                    Editable = false;
                }

                field(Is64BitProcess; Is64BitProcess)
                {
                    ApplicationArea = All;
                    Caption = '64-bit BC Process';
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        LoadInformation();
    end;

    var
        ApplicationVersion: Text[50];
        EnvironmentName: Text[250];
        DeploymentType: Text[50];
        EnvironmentType: Text[50];
        ApplicationFamily: Text[50];
        CurrentCompany: Text[250];
        CurrentUser: Text[250];

        ServerName: Text[250];
        OSVersion: Text[250];
        CPUModel: Text[250];
        ProcessorCount: Integer;
        TotalRAM: Text[50];
        Is64BitOS: Boolean;
        Is64BitProcess: Boolean;

    local procedure LoadInformation()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        ApplicationVersion := GetBaseApplicationVersion();

        EnvironmentName := EnvironmentInformation.GetEnvironmentName();
        ApplicationFamily := EnvironmentInformation.GetApplicationFamily();

        if EnvironmentInformation.IsOnPrem() then
            DeploymentType := 'On-Premises'
        else
            if EnvironmentInformation.IsSaaS() then
                DeploymentType := 'SaaS'
            else
                DeploymentType := 'Unknown';

        if EnvironmentInformation.IsProduction() then
            EnvironmentType := 'Production'
        else
            if EnvironmentInformation.IsSandbox() then
                EnvironmentType := 'Sandbox'
            else
                EnvironmentType := 'Unknown';

        CurrentCompany := CompanyName();
        CurrentUser := UserId();

        LoadServerInformation();
    end;

    local procedure GetBaseApplicationVersion(): Text
    var
        BaseApplicationInfo: ModuleInfo;
        BaseApplicationId: Guid;
    begin
        BaseApplicationId := '437dbf0e-84ff-417a-965d-ed2bb9650972';

        if NavApp.GetModuleInfo(BaseApplicationId, BaseApplicationInfo) then
            exit(Format(BaseApplicationInfo.AppVersion()));

        exit('Unknown');
    end;

    local procedure LoadServerInformation()
    var
        Environment: DotNet DotNetEnvironment;
    begin
        ServerName := Environment.MachineName;
        OSVersion := GetWindowsVersion();
        CPUModel := GetCPUModel();
        ProcessorCount := Environment.ProcessorCount;
        TotalRAM := GetTotalRAM();
        Is64BitOS := Environment.Is64BitOperatingSystem;
        Is64BitProcess := Environment.Is64BitProcess;
    end;

    local procedure GetWindowsVersion(): Text
    var
        BaseKey: DotNet DotNetRegistryKey;
        RegistryKey: DotNet DotNetRegistryKey;
        RegistryHive: DotNet DotNetRegistryHive;
        RegistryView: DotNet DotNetRegistryView;
        ProductName: Text[250];
        DisplayVersion: Text[50];
        CurrentBuild: Text[50];
        CurrentBuildNo: Integer;
    begin
        BaseKey := BaseKey.OpenBaseKey(
            RegistryHive.LocalMachine,
            RegistryView.Registry64);

        RegistryKey := BaseKey.OpenSubKey(
            'SOFTWARE\Microsoft\Windows NT\CurrentVersion');

        if IsNull(RegistryKey) then begin
            BaseKey.Close();
            exit('Unknown');
        end;

        ProductName := Format(RegistryKey.GetValue('ProductName'));
        DisplayVersion := Format(RegistryKey.GetValue('DisplayVersion'));
        CurrentBuild := Format(RegistryKey.GetValue('CurrentBuild'));

        RegistryKey.Close();
        BaseKey.Close();

        if Evaluate(CurrentBuildNo, CurrentBuild) then
            if CurrentBuildNo >= 22000 then
                ProductName :=
                    ProductName.Replace(
                        'Windows 10',
                        'Windows 11');

        ProductName :=
            ProductName.Replace(
                'Microsoft ',
                '');

        if DisplayVersion <> '' then
            exit(ProductName + ' ' + DisplayVersion);

        exit(ProductName);
    end;

    local procedure GetCPUModel(): Text
    var
        Searcher: DotNet DotNetManagementObjectSearcher;
        Collection: DotNet DotNetManagementObjectCollection;
        ManagementObject: DotNet DotNetManagementObject;
        CPUName: Text[250];
    begin
        Searcher := Searcher.ManagementObjectSearcher(
            'SELECT Name FROM Win32_Processor');

        Collection := Searcher.Get();

        foreach ManagementObject in Collection do begin
            CPUName := Format(ManagementObject.Item('Name'));

            Searcher.Dispose();
            Collection.Dispose();

            exit(CPUName);
        end;

        Searcher.Dispose();
        Collection.Dispose();

        exit('Unknown');
    end;

    local procedure GetTotalRAM(): Text
    var
        Searcher: DotNet DotNetManagementObjectSearcher;
        Collection: DotNet DotNetManagementObjectCollection;
        ManagementObject: DotNet DotNetManagementObject;
        TotalMemoryBytes: Decimal;
        TotalMemoryGB: Decimal;
    begin
        Searcher := Searcher.ManagementObjectSearcher(
            'SELECT TotalPhysicalMemory FROM Win32_ComputerSystem');

        Collection := Searcher.Get();

        foreach ManagementObject in Collection do begin
            if Evaluate(
                TotalMemoryBytes,
                Format(ManagementObject.Item('TotalPhysicalMemory')))
            then begin
                TotalMemoryGB :=
                    TotalMemoryBytes /
                    1024 /
                    1024 /
                    1024;

                Searcher.Dispose();
                Collection.Dispose();

                exit(
                    Format(
                        Round(
                            TotalMemoryGB,
                            0.1)) +
                    ' GB');
            end;
        end;

        Searcher.Dispose();
        Collection.Dispose();

        exit('Unknown');
    end;
}