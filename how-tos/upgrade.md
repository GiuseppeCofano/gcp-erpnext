## Come fare upgrade di piattaforma EPRNext

Lanciare il seguente comando (assicurarsi di avere eseguito in precedenza l'autenticazione versio il cluster GKE prima):
```console
> bash upgrade.sh
```

NOTA: lo script esegue l'upgrade dell'Helm chart EPRNext, non fa upgrade del cluster GKE né delle dipendenze di ERPNext (quindi non di MariaDB o di Nginx Controller).
