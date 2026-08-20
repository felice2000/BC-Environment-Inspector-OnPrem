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

                field(ProcessorCount; ProcessorCount)
                {
                    ApplicationArea = All;
                    Caption = 'Logical Processors';
                    Editable = false;
                }

                field(OSVersion; OSVersion)
                {
                    ApplicationArea = All;
                    Caption = 'Operating System';
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
        ProcessorCount: Integer;
        OSVersion: Text[250];
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
        ProcessorCount := Environment.ProcessorCount;

        OSVersion := GetWindowsVersion();

        Is64BitOS := Environment.Is64BitOperatingSystem;
        Is64BitProcess := Environment.Is64BitProcess;
    end;

    local procedure GetWindowsVersion(): Text
    var
        Registry: DotNet DotNetRegistry;
        RegistryKey: DotNet DotNetRegistryKey;
        ProductName: Text[250];
        DisplayVersion: Text[50];
        CurrentBuild: Text[50];
        CurrentBuildNo: Integer;
    begin
        RegistryKey :=
            Registry.LocalMachine.OpenSubKey(
                'SOFTWARE\Microsoft\Windows NT\CurrentVersion');

        if IsNull(RegistryKey) then
            exit('Unknown');

        ProductName := Format(RegistryKey.GetValue('ProductName'));
        DisplayVersion := Format(RegistryKey.GetValue('DisplayVersion'));
        CurrentBuild := Format(RegistryKey.GetValue('CurrentBuild'));

        RegistryKey.Close();

        // Windows 11 may still report "Windows 10"
        // in ProductName for compatibility reasons.
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
}