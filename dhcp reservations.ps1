$scopes = Get-DhcpServerv4Scope -ComputerName al130-dc-02 
        foreach ($scope in $scopes) 
                        { 
                        $reservations = Get-DhcpServerv4Reservation -ComputerName al130-dc-02 -ScopeId $scope.scopeid 
                        $reservations | Out-File ExclusionList.csv -Append 
                        }
