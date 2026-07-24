# Script PowerShell - Création automatique d'utilisateurs AD via fichier CSV
# Auteur : William Eiselé
# Version : 1.1

# Chargement du fichier CSV
$Liste = Import-Csv -Path "C:\Users\Administrateur\Documents\CSV\utilisateurs.csv" -Delimiter ";"

# Boucle pour traiter les utilisateurs 
foreach ($User in $Liste) {
    
    # Extraction des données de l'utilisateur 
    $Prenom   = $User.Firstname
    $Nom      = $User.Lastname
    $Email    = $User."E-mail"
    $BaseUsername = $User.Username

    # Si l'identifiant dépasse 20 caractères, on le coupe automatiquement
    if ($BaseUsername.Length -gt 20) {
        $Username = $BaseUsername.SubString(0, 20)
    } else {
        $Username = $BaseUsername
    }

    # Création du mot de passe temporaire par défaut
    $Password = ConvertTo-SecureString "mdp" -AsPlainText -Force

    # Création de l'utilisateur dans l'Active Directory
   try {
        New-ADUser -Name "$Prenom $Nom" `
                   -SamAccountName $Username `
                   -GivenName $Prenom `
                   -Surname $Nom `
                   -EmailAddress $Email `
                   -UserPrincipalName "$Username@domaine"`
                   -AccountPassword $Password `
                   -ChangePasswordAtLogon $true `
                   -Enabled $true `
                   -ErrorAction Stop 

        # Si la création réussit, on affiche ce message vert
        Write-Host "Succès : L'utilisateur $Username a été créé." -ForegroundColor Green
    } 
    # Si la création échoue, on affiche ce message rouge
    catch {
        
        Write-Warning "Échec pour l'utilisateur $Username : $_"
    }
}