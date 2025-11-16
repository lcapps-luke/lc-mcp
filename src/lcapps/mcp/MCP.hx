package lcapps.mcp;

import haxe.DynamicAccess;
import lcapps.mcp.Data.JsonRpcException;
import lcapps.mcp.Data.JsonRpcRequestMessage;
import lcapps.mcp.Data.JsonRpcResultMessage;
import lcapps.mcp.Data.LogLevel;
import lcapps.mcp.Data.McpInitialize;
import lcapps.mcp.Data.McpTool;
import lcapps.mcp.Data.McpToolResult;
import lcapps.mcp.Data.McpToolsList;
import lcapps.mcp.Data.ToolDefinition;

class MCP {
	private var tools:Map<String, ToolDefinition>;

	public var logLevel:LogLevel;

	public function new(){
		tools = new Map<String, ToolDefinition>();
	}

	public function registerTool(def:ToolDefinition){
		tools.set(def.tool.name, def);
	}

	public function handleMessage(message:JsonRpcRequestMessage):Null<JsonRpcResultMessage> {
		Sys.stderr().writeString('Received command: ${message.method}\n');
		
		var result:Dynamic = switch(message.method){
			case "initialize":
				handleInitialise(message.params);
			case "ping":
				{};
			
			case "logging/setLevel":
				handleSetLoggingLevel(message.params);

			case "tools/list":
				handleToolsListRequest(); //TODO pagination cursor
			case "tools/call":
				handleToolCallRequest(message.params);
			
			case "notifications/initialized":
				null;
			case "notifications/cancelled":
				null;
			default:
				Sys.stderr().writeString('Unrecognised command: ${message.method}\n');
				null;
		}

		if(result == null){
			Sys.stderr().writeString('Null result for command: ${message.method}\n');
			return null;
		}

		return {
			jsonrpc: message.jsonrpc,
			id: message.id,
			result: result
		}
	}
	
	private function handleInitialise(params:DynamicAccess<Dynamic>):McpInitialize {
		return {
			protocolVersion: "2025-06-18",
			serverInfo: {
				name: "file-system",
				title: "File System",
				version: "0.0.1"
			},
			capabilities: {
				logging: {},
				tools: {
					listChanged: true
				}
			}
		}
	}

	private function handleSetLoggingLevel(params:DynamicAccess<Dynamic>){
		var lvlString:String = params.get("level");

		try{
			logLevel = LogLevel.createByName(lvlString);
		}catch(e){
			throw new JsonRpcException(JsonRpcException.INVALID_PARAMS, '$lvlString is not a valid log level', null, e);
		}

		return {};
	}
	
	private function handleToolsListRequest():McpToolsList{
		var toolsList = new Array<McpTool>();
		for(t in tools.iterator()){
			toolsList.push(t.tool);
		}

		return {
			tools: toolsList
		};
	}

	private function handleToolCallRequest(params:DynamicAccess<Dynamic>):McpToolResult {
		var name:String = params.get("name");
		var args:Dynamic = params.get("arguments");

		var tool = tools.get(name);
		return tool.callback(args);
	}
}