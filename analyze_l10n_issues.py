
import json
import os
import re

def analyze_issues():
    base_path = 'c:\\Users\\qozeem\\Desktop\\mobile\\meshkat_elhoda\\lib'
    arb_file = os.path.join(base_path, 'l10n', 'app_en.arb')
    
    method_keys = []
    
    try:
        with open(arb_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        for key, value in data.items():
            if key.startswith('@'): continue
            if '{' in str(value) and '}' in str(value):
                method_keys.append(key)
        
        print(f"Found {len(method_keys)} method keys (with placeholders):")
        for k in method_keys:
            print(f"- {k}")
            
    except Exception as e:
        print(f"Error reading ARB: {e}")
        return

    print("\nScanning Dart files for incorrect usage...")
    for root, dirs, files in os.walk(base_path):
        for file in files:
            if file.endswith('.dart') and not file.startswith('app_localizations'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    for key in method_keys:
                        # naive check for .key followed by something other than (
                        # pattern: .key(?![\s]*\()
                        pattern = r'\.' + re.escape(key) + r'(?![\s]*\()' 
                        matches = re.finditer(pattern, content)
                        for m in matches:
                            line_no = content[:m.start()].count('\n') + 1
                            print(f"Potential issue in {file}:{line_no} -> usage of method '{key}' as property.")
                            
                except Exception as e:
                    pass

if __name__ == '__main__':
    analyze_issues()
