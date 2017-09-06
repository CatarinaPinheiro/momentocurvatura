from flask import Flask, request, send_from_directory
from oct2py import Oct2Py
import json
app = Flask(__name__)

@app.route("/api",methods=["POST"])
def api():
    op = Oct2Py()

    varnames = [
            'base',
            'altura',
            'resistencia_concreto',
            'resistencia_escoamento_aco',
            'resistencia_ultima_aco',
            'deformacao_ultima_aco',
            'forca_dada',
            'numero_camadas_aco',
    ]

    listnames = [
            'posicao_armadura',
            'elem_area_aco'
    ]

    params = request.get_json()

    txt1 = ''.join(['\n'+varname+'='+params[varname] for varname in varnames])

    if params['numero_camadas_aco']!='0':
        txt1+=''.join(['\n'+name+'=['+' '.join(params[name])+']' for name in listnames])

    with open('mphi.m', 'r') as myfile:
        txt2=myfile.read()

    txt = txt1.encode('utf-8')+txt2
    op.eval(txt)
    mphi = op.pull('result')
    return json.dumps(mphi.tolist())

@app.route("/")
def index():
    return app.send_static_file('index.html')

@app.route('/js/<path:path>')
def send_js(path):
    return send_from_directory('js', path)

@app.route('/css/<path:path>')
def send_css(path):
    return send_from_directory('css', path)
