% Script to download TLE from celestrak.com
%
% Input:
% data_path = path where to save the TLE file 
% Stringa_NORAD = NORAD ID as a string
%
% Output:
% TLE in the file data_path\TLE_Stringa_NORAD.txt
% orbitType = LEO, MEO or GEO (string)
%
% Version Mar 07, 2025

function orbitType=download_tle(data_path, Stringa_NORAD)

ExTLE=strcat(data_path, '\TLE_', Stringa_NORAD, '.txt');
file_mancanti=isfile(ExTLE); % Variabile logica, vale 1 se il file esiste, 0 altrimenti
            
if file_mancanti==1
   answer=strcat('File', " ",'TLE_', Stringa_NORAD, '.txt', " ", 'exist');
   disp(answer) 
   disp('   ')
else
   % Acquisizione TLE da celestrak.com
   fullURL = strcat('https://celestrak.com/NORAD/elements/gp.php?CATNR=', Stringa_NORAD);
   disp(strcat('==> TLE ACQUISITION FOR THE SATELLITE', {' '}, Stringa_NORAD))
        
   % Stringa html con i TLE del satellite con numero NORAD(i)
   options=weboptions('Timeout', 30); % Per evitare il timeout dopo 5 s 
   options.CertificateFilename=('');  % Per evitare l'errore "Il certificato ricevuto è scaduto"
   str = webread(fullURL, options);
                                 
   % Salvataggio permanente del TLE corrente scaricato dal NORAD nel file "TLE_NORAD.txt"
   fid4 = fopen(strcat(data_path, '\TLE_', Stringa_NORAD, '.txt'),'w');
   fprintf(fid4, '%s \n', str);
   fclose(fid4);
                
end 
      
orbitType=classifySatelliteFromTLE(ExTLE); % Classifica il satellite corrente

end