# BC Environment Inspector

A lightweight diagnostic extension for **Microsoft Dynamics 365 Business Central On-Premises**.

BC Environment Inspector provides a quick overview of the Business Central environment, Service Tier hardware, operating system, and SQL Server configuration from a single page.

The extension is designed for Business Central administrators, consultants, developers, and support engineers who need to quickly inspect an On-Premises environment.

## Features

### Business Central

Displays information about the current Business Central environment:

- Application Version
- Environment Name
- Deployment Type
- Environment Type
- Application Family
- Current Company
- Current User

### Business Central Service Tier

Retrieves information about the machine running the Business Central Service Tier:

- Server Name
- Operating System
- Windows Version
- CPU Model
- Logical Processors
- Total Physical Memory
- 64-bit Operating System
- 64-bit Business Central Process

Example:

```text
Server Name: SRV-BC01
Operating System: Windows Server 2022 21H2
CPU: Intel(R) Xeon(R) ...
Logical Processors: 16
Total RAM: 64.0 GB
64-bit OS: Yes
64-bit BC Process: Yes
```

Windows information is retrieved from the local Windows Registry, while CPU and memory information are retrieved through WMI.

### SQL Server

Automatically detects the SQL Server configuration used by the current Business Central Server instance.

The extension retrieves:

- SQL Server Name
- SQL Instance Name
- SQL Server Version
- Product Version / Build
- SQL Server Edition
- Current Business Central Database Name

Example:

```text
Server Name: SRV-SQL01
Instance: BC
SQL Version: SQL Server 2022
Product Version: 16.0.x.x
Edition: Standard Edition (64-bit)
Database: BC_PROD
```

When SQL Server uses the default instance, the **Instance** field is left empty.

## Automatic SQL Server Discovery

BC Environment Inspector does not assume that SQL Server is installed on the same machine as the Business Central Service Tier.

The extension automatically:

1. Detects the current Business Central Server instance.
2. Locates the Windows service associated with that instance.
3. Locates the corresponding `CustomSettings.config`.
4. Reads the configured `DatabaseServer` and `DatabaseInstance`.
5. Retrieves the current Business Central database name.
6. Builds the SQL Server connection dynamically.
7. Connects to the configured SQL Server using Windows Integrated Authentication.
8. Retrieves SQL Server version, build, instance, and edition information.

This allows the extension to work with environments where:

```text
Business Central Service Tier
        |
        v
     SRV-BC01
        |
        | Windows Integrated Authentication
        v
     SRV-SQL01
        |
        v
     BC_PROD
```

as well as simpler environments where Business Central and SQL Server are installed on the same machine.

No SQL Server address is hardcoded in the extension.

## Environment Summary

The **Environment Info** action generates a formatted summary containing the most useful environment information.

Example:

```text
=== Business Central Environment ===

Business Central
Application Version: 28.4.53241.0
Environment Name: Production
Deployment Type: On-Premises
Environment Type: Production
Application Family: IT
Company: CRONUS Italia S.p.A.

Business Central Service Tier
Server Name: SRV-BC01
Operating System: Windows Server 2022 21H2
CPU: Intel(R) Xeon(R) ...
Logical Processors: 16
Total RAM: 64.0 GB
64-bit OS: Yes
64-bit BC Process: Yes

SQL Server
Server Name: SRV-SQL01
Instance: BC
SQL Version: SQL Server 2022
Product Version: 16.0.x.x
Edition: Standard Edition (64-bit)
Database: BC_PROD
```

The summary can be useful when collecting environment information for:

- Troubleshooting
- Support requests
- Environment documentation
- Upgrade preparation
- Infrastructure assessment

## Requirements

- Microsoft Dynamics 365 Business Central On-Premises
- Windows-based Business Central Service Tier
- AL extension target set to `OnPrem`
- Access to Windows Management Instrumentation (WMI)
- Access to the Windows Registry
- Access to the Business Central Server instance configuration
- SQL Server connectivity from the Business Central Service Tier

Because the extension uses .NET interoperability and Windows-specific APIs, it is **not compatible with Business Central SaaS**.

## SQL Server Authentication

SQL Server information is retrieved using **Windows Integrated Authentication**.

The extension does not store or require:

- SQL usernames
- SQL passwords
- Connection credentials

The connection is performed using the Windows identity under which the Business Central Server process executes.

The Business Central Service Tier account must therefore have sufficient permissions to connect to the configured Business Central SQL Server and database.

## .NET Dependencies

The project uses .NET interoperability for Windows and SQL Server information.

Main dependencies include:

- `mscorlib`
- `System.Management`
- `Microsoft.Data.SqlClient`

`Microsoft.Data.SqlClient.dll` is included with modern Business Central On-Premises Server installations.

For example, with Business Central 28 it can normally be found under:

```text
C:\Program Files\Microsoft Dynamics 365 Business Central\280\Service\
```

For local AL development, the required assembly can be copied to:

```text
.netpackages\
```

and referenced through the AL assembly probing paths.

Example `.vscode/settings.json`:

```json
{
    "al.assemblyProbingPaths": [
        ".netpackages",
        "C:\\Program Files (x86)\\Reference Assemblies\\Microsoft\\Framework\\.NETFramework\\v4.8",
        "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319"
    ]
}
```

> `.netpackages` should not be committed to the repository.

Example `.gitignore`:

```gitignore
.netpackages/
.alpackages/
*.app
.vscode/launch.json
.vscode/rad.json
```

## Installation

Clone the repository:

```powershell
git clone <repository-url>
```

Then:

1. Open the project in Visual Studio Code.
2. Copy the required .NET assemblies to `.netpackages`.
3. Download the Business Central AL symbols.
4. Compile the extension using the AL Language extension.
5. Publish the generated `.app` package to a Business Central On-Premises environment.
6. Search for **Environment Inspector** in Business Central.

## Project Structure

```text
BC-Environment-Inspector-OnPrem/
├── .vscode/
│   └── settings.json
├── src/
│   ├── DotNet.al
│   └── EnvironmentInfo.Page.al
├── .gitignore
├── app.json
├── LICENSE
└── README.md
```

The extension intentionally keeps the implementation small. The environment information, SQL discovery logic, and environment summary are handled from a single Business Central page.

## How SQL Server Is Detected

The extension determines the current Business Central Server instance using the active session information.

It then identifies the corresponding Windows service:

```text
MicrosoftDynamicsNavServer$<ServerInstance>
```

The service configuration is used to locate the appropriate `CustomSettings.config`.

The following Business Central Server settings are then read:

```text
DatabaseServer
DatabaseInstance
```

The database name is obtained from the current Business Central session.

The resulting SQL data source is therefore constructed dynamically as either:

```text
SRV-SQL01
```

or:

```text
SRV-SQL01\BC
```

depending on whether a named SQL Server instance is configured.

## Security

BC Environment Inspector is designed as a **read-only diagnostic extension**.

It does not modify:

- Business Central data
- Business Central Server configuration
- Windows configuration
- Windows Registry
- SQL Server configuration
- SQL Server databases

The extension only reads environment and configuration information.

However, the information displayed by the extension may include infrastructure details such as:

- Server names
- Database names
- SQL Server versions
- SQL Server editions
- Hardware specifications

Access to the Environment Inspector page should therefore be restricted to appropriate technical or administrative users.

## Compatibility

The extension is currently developed and tested with:

- Microsoft Dynamics 365 Business Central 28 On-Premises
- Windows-based Business Central Service Tier
- Microsoft SQL Server

Other Business Central On-Premises versions may work but could require changes to:

- AL runtime version
- .NET assembly references
- Business Central APIs
- SQL client libraries

Testing on additional Business Central versions is welcome.

## Limitations

- Business Central SaaS is not supported.
- The extension requires .NET interoperability.
- Windows is required for Service Tier hardware discovery.
- WMI must be available to retrieve CPU and memory information.
- SQL Server must be reachable from the Business Central Service Tier.
- The Business Central Service Tier account must be authorized to connect to SQL Server.
- Hardware information currently refers to the **Business Central Service Tier machine**, not the remote SQL Server machine.

## Contributing

Contributions, bug reports, and suggestions are welcome.

If you find an issue or would like to propose an improvement, open an issue or submit a pull request.

Possible future improvements include:

- Additional SQL Server information
- SQL Server host hardware information
- Database size and configuration information
- Business Central Server instance information
- Improved environment report/export functionality

## Disclaimer

This project is an independent community project.

It is not affiliated with, endorsed by, or supported by Microsoft.

Microsoft Dynamics 365 Business Central, Microsoft SQL Server, and Windows are trademarks of Microsoft Corporation.

## License

This project is licensed under the **MIT License**.

See the `LICENSE` file for details.