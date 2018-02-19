private with Alire_Early_Elaboration; pragma Unreferenced (Alire_Early_Elaboration);

with Alire.Containers;
with Alire.Compilers;
with Alire.Dependencies.Vectors;
with Alire.Operating_Systems;
with Alire.Properties;
with Alire.Releases;
with Alire.Repositories.Git;
with Alire.Requisites;
with Alire.Requisites.Platform;
with Alire.Root_Project;

with Semantic_Versioning;

package Alire.Index is

   Releases : Containers.Release_Set;

   subtype Dependencies is Alire.Dependencies.Vectors.Vector;
   
   No_Dependencies : constant Dependencies      := Alire.Dependencies.Vectors.No_Dependencies;
   No_Properties   : constant Properties.Vector := Properties.Vectors.Empty_Vector;
   No_Requisites   : constant Requisites.Tree   := Requisites.Trees.Empty_Tree;

   subtype Release      is Alire.Releases.Release;

   function Register (--  Mandatory
                      Project      : Project_Name;
                      Version      : Semantic_Versioning.Version;                      
                      Description  : Project_Description;
                      Hosting      : Repositories.Repository'Class;
                      Id           : Repositories.Release_Id;                      
                      --  Optional
                      Depends_On     : Dependencies            := No_Dependencies;
                      Properties     : Alire.Properties.Vector := No_Properties;
                      Requisites     : Alire.Requisites.Tree   := No_Requisites;
                      Available_When : Alire.Requisites.Tree   := No_Requisites;
                      Native         : Boolean                 := False) return Release;
   --  Properties are of the Release; currently not used but could support License or other attributes.
   --  Requisites are properties that dependencies have to fulfill, again not used yet.
   --  Available_On are properties the platform has to fulfill; these are checked on registration.

   function Register_Git (Project     : Project_Name;
                          Version     : Semantic_Versioning.Version;
                          Description : Project_Description;
                          Hosting     : URL;
                          Commit      : Repositories.Git.Commit_ID;
                          --  Optional
                          Properties  : Alire.Properties.Vector := No_Properties;
                          Requisites  : Alire.Requisites.Tree   := No_Requisites;
                          Depends_On  : Dependencies            := No_Dependencies) return Release;

   -- Shortcuts to give dependencies:

   function V (Semantic_Version : String) return Semantic_Versioning.Version
                  renames Semantic_Versioning.New_Version;

   function Within_Major (R : Release) return Dependencies;

   function At_Least  (R : Release) return Dependencies;
   function At_Most   (R : Release) return Dependencies;
   function Less_Than (R : Release) return Dependencies;
   function More_Than (R : Release) return Dependencies;
   function Exactly   (R : Release) return Dependencies;
   function Except    (R : Release) return Dependencies;

   subtype Version     is Semantic_Versioning.Version;
   subtype Version_Set is Semantic_Versioning.Version_Set;

   function Within_Major (P : Project_Name; V : Version) return Dependencies;

   function At_Least  (P : Project_Name; V : Version) return Dependencies;
   function At_Most   (P : Project_Name; V : Version) return Dependencies;
   function Less_Than (P : Project_Name; V : Version) return Dependencies;
   function More_Than (P : Project_Name; V : Version) return Dependencies;
   function Exactly   (P : Project_Name; V : Version) return Dependencies;
   function Except    (P : Project_Name; V : Version) return Dependencies;

   --  Shortcuts for properties/requisites:

   use all type Compilers.Compilers;
   use all type Operating_Systems.Operating_Systems;

   use all type Properties.Property'Class; -- for "and" operator
   use all type Requisites.Requisite'Class;
   use all type Requisites.Tree;           -- for logical operators

   Default_Properties : constant Properties.Vector := No_Properties;

   function Verifies (P : Properties.Property'Class) return Properties.Vector;
   function "+"      (P : Properties.Property'Class) return Properties.Vector renames Verifies;

   function Requires (R : Requisites.Requisite'Class) return Requisites.Tree;
   function "+"      (R : Requisites.Requisite'Class) return Requisites.Tree renames Requires;

   --  Specific shortcuts:

   function Compiler_Is_At_Least (V : Compilers.Compilers) return Requisites.Requisite'Class
                       renames Requisites.Platform.Compiler_Is_At_Least;

   function System_is (V : Operating_Systems.Operating_Systems) return Requisites.Requisite'Class
                       renames Requisites.Platform.System_Is;

   ----------------------
   -- Set_Root_Project --
   ----------------------

   function Set_Root_Project (Project    : Alire.Project_Name;
                              Version    : Semantic_Versioning.Version;
                              Depends_On : Alire.Index.Dependencies := Alire.Index.No_Dependencies)
                              return Release renames Root_Project.Set;
   --  This function must be called in the working project alire file.
   --  Otherwise alr does not know what's the current project, and its version and dependencies
   --  The returned Release is the same; this is just a trick to be able to use it in an spec file.
   
private

   function Register_Git (Project     : Project_Name;
                          Version     : Semantic_Versioning.Version;
                          Description : Project_Description;                          
                          Hosting     : URL;
                          Commit      : Repositories.Git.Commit_ID;
                          Properties  : Alire.Properties.Vector := No_Properties;
                          Requisites  : Alire.Requisites.Tree   := No_Requisites;
                          Depends_On  : Dependencies            := No_Dependencies) return Release
   is (Register (Project,
                 Version,
                 Description,
                 Repositories.Git.New_Repository (String (Hosting)),
                 Repositories.Release_Id (Commit),
                 Depends_On,
                 Properties => Properties,
                 Requisites => Requisites,
                 Native     => False));

   use Semantic_Versioning;
   
   use all type Dependencies;

   function Within_Major (R : Release) return Dependencies is
     (New_Dependency (R.Project, Within_Major (R.Version)));

   function At_Least  (R : Release) return Dependencies is
     (New_Dependency (R.Project, At_Least (R.Version)));

   function At_Most   (R : Release) return Dependencies is
     (New_Dependency (R.Project, At_Most (R.Version)));

   function Less_Than (R : Release) return Dependencies is
     (New_Dependency (R.Project, Less_Than (R.Version)));

   function More_Than (R : Release) return Dependencies is
     (New_Dependency (R.Project, More_Than (R.Version)));

   function Exactly   (R : Release) return Dependencies is
     (New_Dependency (R.Project, Exactly (R.Version)));

   function Except    (R : Release) return Dependencies is
     (New_Dependency (R.Project, Except (R.Version)));


   function Within_Major (P : Project_Name; V : Version) return Dependencies is
      (New_Dependency (P, Within_Major (V)));

   function At_Least  (P : Project_Name; V : Version) return Dependencies is
     (New_Dependency (P, At_Least (V)));

   function At_Most   (P : Project_Name; V : Version) return Dependencies is
     (New_Dependency (P, At_Most (V)));

   function Less_Than (P : Project_Name; V : Version) return Dependencies is
     (New_Dependency (P, Less_Than (V)));

   function More_Than (P : Project_Name; V : Version) return Dependencies is
     (New_Dependency (P, More_Than (V)));

   function Exactly   (P : Project_Name; V : Version) return Dependencies is
     (New_Dependency (P, Exactly (V)));

   function Except    (P : Project_Name; V : Version) return Dependencies is
     (New_Dependency (P, Except (V)));


   function Verifies (P : Properties.Property'Class) return Properties.Vector is
     (Properties.Vectors.To_Vector (P, 1));

   function Requires (R : Requisites.Requisite'Class) return Requisites.Tree is
      (Requisites.Trees.Leaf (R));

end Alire.Index;