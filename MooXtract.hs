#!/usr/bin/env runhaskell

{- Copyright (C) 2014 Calvin Beck

   Permission is hereby granted, free of charge, to any person
   obtaining a copy of this software and associated documentation files
   (the "Software"), to deal in the Software without restriction,
   including without limitation the rights to use, copy, modify, merge,
   publish, distribute, sublicense, and/or sell copies of the Software,
   and to permit persons to whom the Software is furnished to do so,
   subject to the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
   ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
-}

import System.Directory
import System.FilePath
import System.Environment
import Data.List.Split


tarExtensions = [".tar.gz", ".tar.bz2", ".gz", ".bz2"]
zipExtensions = [".zip"]

-- File extensions that we allow
legalExtensions = tarExtensions ++ zipExtensions

-- Make directories for each student.
makeDirs :: [FilePath] -> IO [()]
makeDirs paths = sequence $ map (createDirectory . dropExtensions) paths


-- Make directories for students
-- Move the student's submission to their directory
-- Extract the student's submission in their directory


-- We assume that students don't put extra periods in there file names.
-- This assumption is often false...
hasLegalExtension :: FilePath -> Bool
hasLegalExtension name = any (== takeExtensions name ) legalExtensions

-- We want to get the names of the students who broke stuff.
getIllegal :: [FilePath] -> [FilePath]
getIllegal = filter (not . hasLegalExtension)

-- Find all of the students where everything is hopefully fine.
getLegal :: [FilePath] -> [FilePath]
getLegal = filter hasLegalExtension

main = do
  [dir] <- getArgs
  files <- getDirectoryContents dir
  makeDirs $ getLegal files
