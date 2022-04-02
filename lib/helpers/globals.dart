// ignore_for_file: lines_longer_than_80_chars

import 'package:app/helpers/audioManager.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/paintings.dart';

final Map<String, Map<String, dynamic>> globalsPages = {
  'home': {
    'route': (Map<String, dynamic> routes) => HomeScreen(pages: routes),
  },
  'kunstwerken': {
    'children': {
      'schilderijen': {
        'route': (Map<String, dynamic> routes) =>
            PaintingsListPage(pages: routes)
      },
      'zilverwerken': {
        'route': (Map<String, dynamic> routes) => HomeScreen(pages: routes),
      }
    }
  }
};

final AudioManager audioManager = AudioManager();

const Map<String, Map<String, String>> ArtPieces = {
  'dans_om_vrijheidsboom': {
    'name': 'Dans om de vrijheidsboom',
    'kunstenaar': 'Johann Ludwig Hauck',
    'desc':
        'Torenwachter Cornelis Auwerda beheert de Martinitoren van 1762 tot 1808 en ziet de tijdgeest veranderen en is ooggetuige van een groot deel van de gebeurtenissen. Hijzelf is een kind van zijn tijd: geletterd, intelligent en gewiekst. Uit zijn talloze brieven aan het gemeentebestuur over uiteenlopende onderwerpen (kleedgeld, boetes, ongedierte in zijn huis, sleutels) rijst het beeld op van een man die vindt dat de regels niet voor hem gelden en die graag in discussie gaat om zijn zin te krijgen. Iedere andere torenwachter zou direct ontslagen zijn als hij werd betrapt bij het hakken van een doorgang van zijn woning naar de kerk en de toren, maar niet Cornelis Auwerda, die dat kunststukje in 1872 daadwerkelijk probeert te realiseren.',
    'image': 'assets/images/schilderij_johann.jpg',
    'audioFile': 'keys-of-moon-white-petals.mp3'
  },
  'landschap_met_paard': {
    'name': 'landschap met paard',
    'date': '1957',
    'kunstenaar': 'Jan Altink',
    'image': 'assets/images/landschap_met_paard.jpg',
  }
};
