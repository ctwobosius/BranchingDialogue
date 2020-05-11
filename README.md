# BranchingDialogue
A graphical interface that allows the user to create branching (nonlinear) dialogue and export it as a JSON, without having to manually write out the JSON. Made in Godot 3.2.

The format for the JSON dialogue is a dictionary where each key is "d" concatenated with an ID number. The values are arrays of metadata of the form [Speaker, Speaker Text, Responses] where Speaker and Speaker Text are strings, and Responses is optional (ie: the Responses field could be empty). Responses is another dictionary where Response's key is the response to the speaker text and the value is the "d#" key to lookup in the main dictionary that continues the conversation. 

For example:

{

  "d0":
  
    ["Jim","Hello User!",{"Hi, Jim!": "d1","I don't know you.":"d2"}],
    
  "d1":
  
    ["Jim","Thanks for talking! Well, I have to get back to work!"],
    
  "d2":
  
    ["Jim","You're a rude child! I heavily dislike you!"]
    
}
