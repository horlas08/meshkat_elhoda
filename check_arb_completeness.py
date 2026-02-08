
import json
import os
import glob
import sys

def load_arb_keys(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            return set(k for k in data.keys() if not k.startswith('@'))
    except Exception as e:
        return set()

def main():
    base_path = 'lib/l10n'
    en_path = os.path.join(base_path, 'app_en.arb')
    report_file = 'arb_report.txt'
    
    if not os.path.exists(en_path):
        return

    en_keys = load_arb_keys(en_path)
    
    with open(report_file, 'w', encoding='utf-8') as report:
        report.write(f"Base English Keys Count: {len(en_keys)}\n")

        arb_files = glob.glob(os.path.join(base_path, 'app_*.arb'))
        
        all_good = True
        
        for arb_file in arb_files:
            if arb_file.endswith('app_en.arb'):
                continue
                
            lang_code = os.path.basename(arb_file).replace('app_', '').replace('.arb', '')
            keys = load_arb_keys(arb_file)
            
            missing_keys = en_keys - keys
            
            if missing_keys:
                all_good = False
                report.write(f"\n❌ {lang_code.upper()} is missing {len(missing_keys)} keys:\n")
                for k in sorted(missing_keys):
                    report.write(f"  - {k}\n")
            else:
                report.write(f"✅ {lang_code.upper()} matches English keys.\n")

        if all_good:
            report.write("\n🎉 All ARB files are in sync with English!\n")
            
    print(f"Report written to {report_file}")

if __name__ == '__main__':
    main()
