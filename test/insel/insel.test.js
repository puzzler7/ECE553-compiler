const fs = require('fs');
const { spawnSync, spawn } = require('child_process');
const { test, it } = require('@jest/globals');

const cmMakeMsg = '[New bindings added.]';


const getRelativePathOfTests = (dir) => {
    return fs.readdirSync(dir)
             .filter(fileName => /^.*\.tig$/.exec(fileName))
             .map(fileName => dir + fileName);

}

const getScript = (filePath) => {
    return `CM.make "src/insel/sources.cm"; Main.compile("${filePath}");`
}

const getTypecheckScript = (filePath) => {
    return `CM.make "src/typechecker/sources.cm"; Main.typecheckOnly("${filePath}");`
}

describe('The textbook tests', () => {
    const cases = getRelativePathOfTests('test/testcases/');

    test.each(cases)(
        'compiles %s correctly',
        (testFile) => {
            const compileResults = spawnSync(`sml`, { input: getScript(testFile) })
            expect(compileResults.error).toBeFalsy();
            expect(compileResults.stderr.toString()).toBe('');

            const stdout = compileResults.stdout.toString()
            expect(stdout.includes(cmMakeMsg)).toBeTruthy();
            expect(stdout.slice(stdout.indexOf(cmMakeMsg) + cmMakeMsg.length)).toMatchSnapshot();
        }
    );

    test.each(cases)(
        'typechecks %s correctly',
        (testFile) => {
            const compileResults = spawnSync(`sml`, { input: getScript(testFile) })
            const typecheckResults = spawnSync(`sml`, { input: getTypecheckScript(testFile) })

            const compileStdout = compileResults.stdout.toString()
            const typecheckStdout = typecheckResults.stdout.toString()
            expect(
                compileStdout.slice(compileStdout.indexOf(cmMakeMsg) + cmMakeMsg.length, compileStdout.indexOf('EXP('))
                ===
                typecheckStdout.slice(typecheckStdout.indexOf(cmMakeMsg) + cmMakeMsg.length, typecheckStdout.indexOf('val it = () : unit'))
            ).toBeTruthy();
        }
    );
})