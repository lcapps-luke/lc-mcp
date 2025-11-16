package lcapps.mcp;

import haxe.Json;
import haxe.io.Eof;
import haxe.io.Input;
import haxe.io.Output;
import lcapps.mcp.Data.JsonRpcErrorMessage;
import lcapps.mcp.Data.JsonRpcException;
import lcapps.mcp.Data.JsonRpcRequestMessage;

class InputOutputTransport {
	private var mcp:MCP;

	private var input:Input;
	private var output:Output;

	public var running:Bool = true;
	
	public function new(mcp:MCP, input:Input, output:Output){
		this.mcp = mcp;

		this.input = input;
		this.output = output;
	}

	public function run(){
		while(running){
			try{
				handleLine(input.readLine());
			}catch(e:Eof){
				Sys.sleep(0.3);
			}
		}
	}

	public function handleLine(line:String){
		try{
			var message = Json.parse(line);
			handleMessage(message);
		}catch(e){
			var jsonParseErrorResponse:JsonRpcErrorMessage = {
				jsonrpc: "2.0",
				id: null,
				error: {
					code: JsonRpcException.PARSE_ERROR,
					message: e.message
				}
			}
			output.writeString(Json.stringify(jsonParseErrorResponse));
			output.writeString("\r\n");
			output.flush();
		}
	}

	public function handleMessage(message:JsonRpcRequestMessage){
		try{
			var response = mcp.handleMessage(message);

			Sys.stderr().writeString(Json.stringify({
				request: message,
				response: response
			}));

			if(response != null){
				output.writeString(Json.stringify(response));
				output.writeString("\r\n");
				output.flush();
			}
		}catch(e:JsonRpcException){
			var jsonParseErrorResponse:JsonRpcErrorMessage = {
				jsonrpc: "2.0",
				id: message.id,
				error: {
					code: e.code,
					message: e.message,
					data: e.data
				}
			}
			output.writeString(Json.stringify(jsonParseErrorResponse));
			output.writeString("\r\n");
			output.flush();
		}catch(e){

			Sys.stderr().writeString(e.stack.toString());
			var jsonParseErrorResponse:JsonRpcErrorMessage = {
				jsonrpc: "2.0",
				id: message.id,
				error: {
					code: JsonRpcException.INTERNAL_ERROR,
					message: e.message,
					data: e.details
				}
			}
			output.writeString(Json.stringify(jsonParseErrorResponse));
			output.writeString("\r\n");
			output.flush();
		}
	}
}