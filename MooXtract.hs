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
import Data.List
import Control.Arrow
import Codec.Archive.Zip
import Codec.Archive.Tar as Tar
import Codec.Compression.GZip as GZip
import Codec.Compression.BZip as BZip
import qualified Data.ByteString.Lazy as BS


-- | Directory entries we wish to ignore
dirIgnore = [".", ".."]

-- | File extensions for different archive formats
tarExtensions = [".tar"]
tgzExtensions = [".tar.gz", ".gz"]
tbzExtensions = ["tar.bz2", ".bz2"]
zipExtensions = [".zip"]

-- | All file extensions that we allow
legalExtensions = tarExtensions ++ tgzExtensions ++ tbzExtensions ++ zipExtensions


main = do
  files <- getDirectoryContents "."
  let (legal, illegal) = partition hasLegalExtension $ filter (`notElem` dirIgnore) files
  putStrLn "Possible baddies:"
  putStrLn $ intercalate "\n" illegal
  putStrLn "Extracting..."
  mapM makeDir legal
  putStrLn "Done!"


-- | Assumes that students don't put extra periods in there file names. Often false.
hasLegalExtension :: FilePath -> Bool
hasLegalExtension name = takeExtensions name `elem` legalExtensions

-- | Create a submission directory and extract archive for submission in it.
makeDir path = do
  createDirectory dir
  renameFile path archivePath
  extractSub archivePath
    where dir = dropExtensions path
          archivePath = joinPath [dir, path]

-- | Extract archive depending on file extension.
extractSub path
  | extension `elem` tarExtensions = extract dir path
  | extension `elem` tgzExtensions = extractTgz dir path
  | extension `elem` tbzExtensions = extractTbz2 dir path
  | extension `elem` zipExtensions = extractZip dir path
  | otherwise = error $ "Unknown extension: " ++ extension
  where extension = takeExtensions path
        dir = dropFileName path

-- | Blatantly stolen from here: http://hackage.haskell.org/package/tar-0.4.0.1/docs/Codec-Archive-Tar.html
extractTgz dir tar = unpack dir . Tar.read . GZip.decompress =<< BS.readFile tar
extractTbz2 dir tar = unpack dir . Tar.read . BZip.decompress =<< BS.readFile tar

-- | Unzip a .zip archive.
extractZip path archive = do
      prevPath <- getCurrentDirectory
      setCurrentDirectory path
      archData <- BS.readFile archiveFile
      extractFilesFromArchive [] (toArchive archData)
      setCurrentDirectory prevPath
        where
          archiveFile = takeFileName archive
