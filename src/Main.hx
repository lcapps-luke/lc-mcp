package;

import haxe.DynamicAccess;
import haxe.Json;
import lcapps.mcp.Data.McpToolResult;
import lcapps.mcp.InputOutputTransport;
import lcapps.mcp.MCP;
import sys.FileSystem;

class Main{
	public static function main(){
		var mcp = new MCP();
		mcp.registerTool({
			tool: {
				name: "list-directory",
				description: "Lists the content of a directory",
				title: "List Directory",
				inputSchema: {
					type: "object",
					properties: {
						directory: {
							type: "string",
							description: "The directory path to list content for"
						}
					},
					required: ["directory"]
				},
				outputSchema: {
					type: "object",
					properties: {
						items: {
							type: "array",
							items: {
								type: "string",
								description: "An item in the directory"
							},
							description: "A List of items in the directory"
						} 
					},
					required: ["items"]
				}
			},
			callback: onListDirectory
		});


		var stdioTransport = new InputOutputTransport(mcp, Sys.stdin(), Sys.stdout());
		stdioTransport.run();

		// mcp protocol obj - routes messages, creates responses
		// transport obj - abstract, converts messages to io and back
	}

	private static function onListDirectory(args:DynamicAccess<Dynamic>):McpToolResult {
		var dir = args.get("directory");

		var list = {
			items: FileSystem.readDirectory(dir)
		};

		return {
			content: [
				{
					type: "text",
					text: Json.stringify(list)
				}
			],
			structuredContent: list
		};
	}
}