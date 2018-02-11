package body Alire.Index is

   --------------
   -- Register --
   --------------

   function Register (Project     : Project_Name;
                      Version     : Semantic_Versioning.Version;
                      Hosting     : Repositories.Repository'Class;
                      Id          : Repositories.Release_Id;
                      Depends_On  : Dependencies := Nothing) return Release
   is
   begin
      return Rel : constant Alire.Releases.Release :=
        Alire.Releases.New_Release (Project,
                                    Version,
                                    Hosting,
                                    Id,
                                    Depends_On)
      do
         if Releases.Contains (Rel) then
            Log ("Attempt to register duplicate versions: " & Rel.Milestone_Image, Warning);
         else
            Releases.Insert (Rel);
         end if;
      end return;
   end Register;

end Alire.Index;
