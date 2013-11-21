package ir.tahanzadeh.display
{
import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.net.*;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import ir.tahanzadeh.BtFunction;
import ir.tahanzadeh.stype.deluxes.SBoolean;
import ir.tahanzadeh.stype.natives.SFile;


public class AppMenu
{
	public var	menuXml:XML,
				appMenu:NativeMenu,
				dictionary:Dictionary;
	
	
	
	/**
	 * 
	 * class constructor
	 * 
	 */
	public function AppMenu(menuXml:XML=null, appMenu:NativeMenu=null)
	{
		dictionary = new Dictionary();
		
		if(menuXml)
		{
			this.menuXml = menuXml;
			
			this.appMenu = new NativeMenu();
			
			for(var i:int=0 ; i<menuXml.menu.length() ; ++i)
			{
				createMenu(menuXml.menu[i], this.appMenu, '');
			}	
		}
		else if(appMenu)
		{
			this.appMenu = appMenu;
		}
	}//eof
	
	
	
	
	/**
	 * 
	 * iterate over xml data and create menu items
	 * 
	 */
	private function createMenu(menuXml:XML, menu:NativeMenu, parentId:String):void
	{
		var nmi:NativeMenuItem = new NativeMenuItem(menuXml.@label, (menuXml.@isSeparator=='true'));
		
		nmi.enabled = !(menuXml.@enabled=='false');
		
		nmi.checked = (menuXml.@checked=='true');
		
		if(BtFunction.TrimString(menuXml.@href)!='')
		{
			nmi.addEventListener(
				Event.SELECT,
				function(event:Event):void
					{navigateToURL(new URLRequest(menuXml.@href));}
			);
		}
		
		if(BtFunction.TrimString(menuXml.@keyEquivalent)!='')
		{
			nmi.keyEquivalent = menuXml.@keyEquivalent;
		}
		
		if(menuXml.@func == "toggleBool")
		{
			dictionary[parentId+menuXml.@id.toString()] ||= new SBoolean(false);
			
			nmi.checked = false;
			
			nmi.addEventListener(Event.SELECT, function(event:Event):void
				{
					SBoolean(dictionary[parentId+menuXml.@id.toString()]).value = !SBoolean(dictionary[parentId+menuXml.@id.toString()]).value;
				}
			);
			
			SBoolean(dictionary[parentId+menuXml.@id.toString()]).signal.change.add(function():void
				{
					nmi.checked = SBoolean(dictionary[parentId+menuXml.@id.toString()]).value;
				}
			);
		}
		
		if(menuXml.browse.length()>0)
		{
			dictionary[parentId+menuXml.@id.toString()] ||= new SFile();
			
			var typeFilter:Array = [];
			
			for each(var ff:XML in menuXml.browse.filefilter)
			{
				typeFilter.push(new FileFilter(ff.@description, ff.@extension))
			}
			
			if(menuXml.browse.@func == 'open')
			{
				nmi.addEventListener(Event.SELECT, function(event:Event):void
					{
						SFile(dictionary[parentId+menuXml.@id.toString()]).value
							.browseForOpen(menuXml.browse.@title, typeFilter);
					}
				);
			}
			
			if(menuXml.browse.@func == 'save')
			{
				nmi.addEventListener(Event.SELECT, function(event:Event):void
					{
						SFile(dictionary[parentId+menuXml.@id.toString()]).value
							.browseForSave(menuXml.browse.@title);
					}
				);
			}
		}
		
		nmi.data = parentId+menuXml.@id.toString();
		
		if(menuXml.menu.length()>0)
		{
			var nm:NativeMenu = new NativeMenu();
			
			for(var i:int=0 ; i<menuXml.menu.length() ; ++i)
			{
				createMenu(menuXml.menu[i], nm, parentId+menuXml.@id+".");
			}
			
			nmi.submenu = nm;
		}
		
		menu.addItem(nmi);
	}//eof
	
	
	
	
	/**
	 * 
	 * get native menu item by id
	 * 
	 */
	private function getNmiByArray(path:Array , menu:NativeMenu , depth:int=1):NativeMenuItem
	{
		var str:String = path[0];
		
		var i:int;
		
		for(i=1; i<depth; ++i)
		{
			str += ('.'+path[i]);
		}
		
		for(i=0 ; i<menu.items.length ; ++i)
		{
			if(String(menu.items[i].data) == str)
			{
				if(path.length == depth)
				{
					return menu.items[i];
				}
				else
				{
					return getNmiByArray(path, NativeMenuItem(menu.items[i]).submenu, depth+1);
				}
			}
		}
		return null;
	}//eof
	
	
	
	
	/**
	 * 
	 * 
	 * 
	 */
	public function getNmiById(str:String, delim:*=null):NativeMenuItem
	{
		return getNmiByArray(str.split(delim?delim:'.') , appMenu);
	}
	
	
	
	
}//eoc
}//eop
