# Define ASCII art frames for a simple dancing character
$frames = (
    "
       (\_/)
      ( ^_^ )  
      <(   )>  
       _|_|_   
    ", # Standing, ready to groove
    "
       (\_/)
      \( ^_^)/  
      <(   )>  
       _|_|_   
    ", # Arms up slightly
    "
       (\_/)
      \(o_o)/  
      <(   )>  
       _|_|_   
    ", # Arms fully up
    "
       (\_/)
      \(o_o)/  
      /(   )\  
       _|_|_   
    ", # Hands and feet stretched out
    "
       (\_/)
      (o_o)  
      /(   )\  
       _|_|_   
    ", # Steady stance
    "
      (\_/)
      (o_o)  
     /<(   )>\  
       _|_|_   
    ", # Widening out
    "
      (\_/)
      (o_o)  
     /<( )>\  
       _|_|_   
    ", # Back to center slightly
    "
      (\_/)
      (^_^)
      <(   )>  
       _|_|_   
    ", # A happy pose
    "
      (\_/)
     \(o_o)/  
     /(   )\  
      _|_|_   
    ", # Big motion!
    "
       (\_/)
      (o_o)  
     \(   )/  
      _|_|_  
    ", # Small jump
    "
       (\_/)
      (~o_o~)  
     <(   )>  
      _|_|_   
    ", # Waving to the audience
    "
      _(\_/)_  
      (o_o)  
     <(   )>  
      _|_|_   
    ", # Lean left
    "
      (\_/)_  
      (o_o)  
     <(   )>  
      _|_|_   
    ", # Lean right
    "
       (\_/)
      (O_O)   
     \<(   )>/  
      _|_|_   
    ", # Dramatic pose!
    "
       (\_/)
      ( ^_^ )   
      <(   )>   
       _|_|_   
    " # Back to neutral, ready to start again!
)


$i = 0
while ($true) {
    Clear-Host
    Write-Host $frames[$i]
    Start-Sleep -Milliseconds 250 # Adjust for desired speed

    $i++
    if ($i -ge $frames.Length) {
        $i = 0 # Loop back to the first frame
    }
}