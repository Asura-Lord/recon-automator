#!/usr/bin/env python3
import argparse, json, os, xml.etree.ElementTree as ET
from glob import glob

def parse_nmap_xml(xml_path):
    data={"hosts":[]}
    try:
        tree=ET.parse(xml_path); root=tree.getroot()
    except Exception as e:
        return {"error":str(e)}
    for host in root.findall("host"):
        h={"addresses":[],"ports":[]}
        for addr in host.findall("address"):
            h["addresses"].append(addr.attrib)
        for ports in host.findall("ports"):
            for p in ports.findall("port"):
                port={"portid":p.attrib.get("portid"), "protocol":p.attrib.get("protocol")}
                state=p.find("state"); service=p.find("service")
                if state is not None: port["state"]=state.attrib
                if service is not None: port["service"]=service.attrib
                h["ports"].append(port)
        data["hosts"].append(h)
    return data

def read_text_file(path):
    try:
        with open(path,'r',errors='ignore') as f: return f.read()
    except: return None

p=argparse.ArgumentParser()
p.add_argument("--input", required=True)
p.add_argument("--output", required=True)
args=p.parse_args()

out={"target": os.path.basename(args.input.rstrip('/\\')), "nmap":{}, "http":{}, "dir":{}}
nmap_xmls=glob(os.path.join(args.input, "nmap", "*.xml"))
if nmap_xmls:
    out["nmap"]=parse_nmap_xml(nmap_xmls[0])
else:
    out["nmap"]={"note":"no nmap xml found"}

http_dir=os.path.join(args.input, "http")
if os.path.isdir(http_dir):
    for f in os.listdir(http_dir):
        out["http"][f]=read_text_file(os.path.join(http_dir,f))

dir_dir=os.path.join(args.input, "dir")
if os.path.isdir(dir_dir):
    for f in os.listdir(dir_dir):
        path=os.path.join(dir_dir,f)
        content=read_text_file(path)
        if f.endswith(".json"):
            try: out["dir"][f]=json.loads(content)
            except: out["dir"][f]={"raw":content}
        else:
            out["dir"][f]=content

os.makedirs(os.path.dirname(args.output), exist_ok=True)
with open(args.output,"w") as fh: json.dump(out, fh, indent=2)
print(f"[+] Wrote summary to {args.output}")
