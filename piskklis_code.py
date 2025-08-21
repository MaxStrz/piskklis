import requests
from typing import List, Dict, Optional
from urllib.parse import quote

# Definiere eine eigene Exception-Klasse für diesen Fall
class NoConceptsFoundError(Exception):
    """Wird ausgelöst, wenn keine Konzepte gefunden wurden."""
    pass


class Piskklis_SnomedAPI:
    def __init__(self, base_url: str = "http://snowstorm:8080/fhir"):
        """
        Initialisiert die Schnittstelle zur SNOMED-API.
        :param base_url: Basis-URL der FHIR-Schnittstelle von Snowstorm
        """
        self.base_url = base_url.rstrip('/')

    # 'https://browser.ihtsdotools.org/fhir
    # /ValueSet/$expand?url=http%3A%2F%2Fsnomed.info%2Fsct%3Ffhir_vs&count=10&offset=1&filter=myocardial'

    def get_concepts(self, name: str) -> Optional[List[Dict]]:
        """
        Sucht SNOMED CT Konzepte nach einem Namen und gibt eine Liste von Konzepten zurück.

        :param name: Name oder Teilname des gesuchten Konzepts (als String)
        :return: Liste von Dictionaries mit 'code' und 'display' der gefundenen Konzepte, oder None bei Fehler
        """

        # 'http://snowstorm:8080/fhir/ValueSet/$expand?url=http://snomed.info/sct?fhir_vs&count=10&filter=cardiac'
        url = f"{self.base_url}/ValueSet/$expand"
        params = {
            "url": "http://snomed.info/sct?fhir_vs",
            "count": 10,
            "filter": name
        }
        try:
            resp = requests.get(url, params=params, timeout=30)
            resp.raise_for_status()
            print(resp.json())
            if resp.json().get('expansion').get('total') > 0:
                concepts = resp.json()['expansion']['contains']
            else:
                # Wenn keine Konzepte gefunden wurden, eine eigene Exception werfen
                raise NoConceptsFoundError(f"Keine Konzepte für '{name}' gefunden.")
            
            return concepts
        
        except NoConceptsFoundError as e:
            print(f"[Fehler] {e}")
            return None

        except(requests.RequestException, KeyError) as e:
            print(f"[Fehler] get_concepts({name}): {e}")
            return None
        
    def get_parents(self, smct_code: str) -> Optional[List[Dict]]:
        """
        Gibt die Elternkonzepte eines SNOMED CT Codes als Liste zurück.

        :param smct_code: SNOMED CT Code (als String), z.B. "34402009" für Rektum
        :return: Liste von Dictionaries mit 'code' und 'display' der Eltern, oder None bei Fehler
        """
        # ECL-Ausdruck: ">" für direkte Eltern
        ecl = f'>{smct_code}'
        # ECL-Ausdruck URL-kodieren
        ecl_encoded = quote(ecl, safe='')
        # Ziel-Endpoint zusammensetzen
        url = f"{self.base_url}/ValueSet/$expand"
        # Parameter für GET-Anfrage vorbereiten
        params = {
            "url": f"http://snomed.info/sct?fhir_vs=ecl/{ecl_encoded}"
        }
        try:
            # GET-Request an die API senden (Timeout für Robustheit)
            resp = requests.get(url, params=params, timeout=30)
            # Bei Fehler HTTP-Exception werfen
            resp.raise_for_status()
            # Antwort als JSON interpretieren
            data = resp.json()
            # Eltern aus der Expansion extrahieren, sonst leere Liste
            return data.get('expansion', {}).get('contains', [])
        except (requests.RequestException, KeyError) as e:
            # Fehlerausgabe (könnte auch Logging sein)
            print(f"[Fehler] get_parents({smct_code}): {e}")
            return None

    def get_concept_name(self, concept_code: str) -> Optional[str]:
        """
        Gibt den Displaynamen (Bezeichnung) eines SNOMED CT Konzepts zurück.

        :param concept_code: SNOMED CT Code (als String)
        :return: Name/Display des Konzepts als String, oder None bei Fehler
        """
        url = f"{self.base_url}/CodeSystem/$lookup"
        params = {
            "system": "http://snomed.info/sct",
            "code": str(concept_code)
        }
        try:
            # Anfrage an die API senden (Timeout wie oben)
            resp = requests.get(url, params=params, timeout=30)
            resp.raise_for_status()
            data = resp.json()
            # Im "parameter"-Array nach einem Eintrag mit Name 'display' suchen
            for param in data.get('parameter', []):
                if param.get('name') == 'display':
                    return param.get('valueString')
            # Falls kein Display gefunden wird, None zurückgeben
            return None
        except (requests.RequestException, KeyError) as e:
            print(f"[Fehler] get_concept_name({concept_code}): {e}")
            return None
