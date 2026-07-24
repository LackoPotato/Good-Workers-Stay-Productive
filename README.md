# Source Code for my Submission for the Stop Killing Game's Jam!  

## To add new applications:  
    All applications are Scenes with a PCWindow as a root node.  
    [Only required if you want to launch apps using app icons found on the desktop] To register it with the Desktop, add it and an associated UNIQUE id to the variable [window_scenes:Dictionary[int,PackedScene]].  

## To launch new applications:  
    [Using an ID and Scene] Use the function [create_window]  
        The ID is required as it is how we track active windows and if a window has already been launched.  
    [Using an App Icon] Make a new Button (TextureButton, Button or similar)  
        Bind pressed to the function [app_icon_pressed] with an additional binded integer (being the app id you registered previously)  
            If you can't find the ability to bind an integer, use advanced options.  
        Now you can double tap the button to launch an app.  

## Enabling apps on certain days
    If you registered the task to the pc.gd scene and added a corresponding button to launch the app. You may have noticed it is still there in different days, unlike ingame where some apps appear. This is handled by [task_apps] where each day, a sub-array of this Array is taken, from 0 to the day. [TXT, MSG, SOMETHING] on day 1 will unlock the buttons for [TXT, MSG]. If you don't want to unlock something on that day, use a null entry instead. So to make your app available by a certain day x, add it to index x.  

## To add new tasks:  
    Extend the Task class with the required functions:  
        func get_task_string() -> String  
            Returns the sentence used to show active tasks in the Checklist app. (e.g. "Number of balloons popped")  
        func get_progress_string() -> String  
            Returns the sentence used to show progress on the task in the Checklist app. (e.g. "5 out of 6")  
        func add_progress(progress:int) -> bool  
            Adds progress to the task, returning true if the task is finished
        func get_rewarded_productivity() -> int
            Returns the amount of productivity given to the player  
        func get_type() -> ValidTasks  
            Returns the type of task from the enum ValidTasks  

    Then, add an entry of the task to the enum ValidTasks, this is required for generic task creation, used by the GameManager.  
    Finally, add a case to the function [Task.make_task]  to return your new Task  
```
  static func make_task(chosen:ValidTasks) -> Task:
	match chosen:
		ValidTasks.TEXT:
			return TextEditor.new()
		ValidTasks.MSG:
			return Messenger.new()
		ValidTasks.BUG:
			return Bug.new()
        ValidTasks.YOURTASKENUM:
            return YourTask.new() #or however you decide to make a new task
		_:
			push_error("Task %s is not a valid task" % chosen)
	return null
```

## To enable the task ingame:
    Like enabling apps on certain days, to enable a task on a day, add the ValidTask enum entry in the corresponding index. For more information, refer back to enabling apps on certain days.

## Adding a new website to the browser:  
    The browser [code/applications/notscape/notscape.gd] adds apps by keeping a dictionary called [pages(String,Node)]. To add a new website, add the Node as a child of [page_root] and register it to the pages dictionary with the key (a String) being the URL to the page.

## Adding forbidden URL's:  
    Certain URL's can be labled as forbidden and give a special error page instead of the usual NOTFOUND. This can be done by adding the URL to [forbidden_pages]


     
