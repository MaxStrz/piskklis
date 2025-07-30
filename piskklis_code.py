import requests
from urllib.parse import quote

def get_parents(smct_code):
    ecl_encoded = quote(f'>{smct_code}', safe='')
    url = f"http://snowstorm:8080/fhir/ValueSet/$expand?url=http://snomed.info/sct?fhir_vs=ecl/{ecl_encoded}"
    response = requests.get(url).json() #_base, params=params)
    parents = response['expansion']['contains']
    return parents

def get_concept_name(concept_code: int) -> str:
    url = "http://snowstorm:8080/fhir/CodeSystem/$lookup"
    concept_code = str(concept_code)
    params = {
        "system": "http://snomed.info/sct",
        "code": concept_code
        }
    response = requests.get(url, params=params)
    concept = response.json()['parameter'][1]['valueString']
    return concept