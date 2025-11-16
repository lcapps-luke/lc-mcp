package lcapps.mcp;

import haxe.DynamicAccess;
import haxe.Exception;

typedef JsonRpcMessage = {
	var jsonrpc:String; // 2.0
	var id:Int;
}

typedef JsonRpcRequestMessage = JsonRpcMessage & {
	var method:String;
	var params:Dynamic;
}

typedef JsonRpcResultMessage = JsonRpcMessage & {
	var result:Dynamic;
}

typedef JsonRpcErrorMessage = JsonRpcMessage & {
	var error:JsonRpcError;
}

typedef JsonRpcError = {
	var code:Int;
	var message:String;
	var ?data:Dynamic;
}

class JsonRpcException extends Exception{
	public static inline var PARSE_ERROR = -32700;
	public static inline var INVALID_REQUEST = -32600;
	public static inline var METHOD_NOT_FOUND = -32601;
	public static inline var INVALID_PARAMS = -32602;
	public static inline var INTERNAL_ERROR = -32603;
	public static inline var SERVER_ERROR = -32000;

	public var code(default, null):Int;
	public var data(default, null):Dynamic;
	public function new(code:Int, message:String, ?data:Dynamic, ?previous:Exception){
		super(message, previous);
		this.code = code;
		this.data = data;
	}
}

typedef McpInitialize = {
	var protocolVersion:String;
	var capabilities:McpCapabilities;
	var serverInfo:McpEndpointInfo;
	var ?instructions:String;
}

typedef McpCapabilities = {
	//client 
	var ?roots:McpCapabilitiesItem;
	var ?sampling:McpCapabilitiesItem;
	var ?elicitation:McpCapabilitiesItem;

	//server
	var ?logging:McpCapabilitiesItem;
	var ?prompts:McpCapabilitiesItem;
	var ?resources:McpCapabilitiesItem;
	var ?tools:McpCapabilitiesItem;
	var ?completions:McpCapabilitiesItem;

	//both
	var ?experimental:McpCapabilitiesItem;
}

typedef McpCapabilitiesItem = {
	var ?listChanged:Bool;
	var ?subscribe:Bool;
}

typedef McpEndpointInfo = {
	var name:String;
	var title:String;
	var version:String;
}

typedef McpToolsList = {
	var tools:Array<McpTool>;
	var ?nextCursor:String;
}

typedef McpTool = {
	var name:String;
	var title:String;
	var description:String;
	var inputSchema:JsonSchema;
	var ?outputSchema:JsonSchema;
}

typedef McpToolResult = {
	var content:Array<McpToolResultContent>;
	var ?structuredContent:Dynamic;
}

typedef McpToolResultContent = {
	var type:String; // text, image, audio, resource_link
	var ?text:String;
	var ?data:String; // b64
	var ?mimeType:String;
	var ?uri:String;
	var ?name:String;
	var ?description:String;
}

typedef JsonSchema = {
	var type:String; //array, boolean, null, integer, number, object, string, 
	var ?properties:DynamicAccess<JsonSchema>;
	var ?required:Array<String>;
	var ?items:JsonSchema;
	var ?description:String;
}

typedef ToolDefinition = {
	var tool:McpTool;
	var callback:DynamicAccess<Dynamic> -> McpToolResult;
}

enum LogLevel{
	debug;
	info;
	notice;
	warning;
	error;
	critical;
	alert;
	emergency;
}