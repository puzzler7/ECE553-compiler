const fs = require('fs');
const { spawnSync } = require('child_process');
const { test, it } = require('@jest/globals');

const getRelativePathOfTests = (dir) => {
    return fs.readdirSync(dir)
             .filter(fileName => /^.*\.tig$/.exec(fileName))
             .map(fileName => dir + fileName);

}

describe('When building with Mlton', () => {
    it('checks that Mlton exists and builds lexer without crashing', () => {
        const checkMltonExists = spawnSync('mlton')
        expect(checkMltonExists.error).toBeFalsy();
        expect(checkMltonExists.stdout.toString()).toBe('MLton 20210117\n');

        const checkBuild = spawnSync('mlton', [
            '-default-ann',
            'allowVectorExps true',
            '-output',
            'build/lexerParse',
            'src/lexer/sources.mlb'
        ]);
        expect(checkBuild.error).toBeFalsy();
        expect(checkBuild.stderr.toString().length).toBe(0);
    });
})

describe('Maverick\'s cool custom tests', () => {
    const cases = getRelativePathOfTests('test/lexer/');
    
    test.each(cases)(
        'parses %s correctly',
        (testFile) => {
            const parseResults = spawnSync('build/lexerParse', [testFile]);
            expect(parseResults.error).toBeFalsy();
            console.log(parseResults.stderr.toString());
            expect(parseResults.stderr.toString().length).toBe(0);
            expect(parseResults.stdout.toString()).toMatchSnapshot();
        }
    );
})

describe('The textbook tests', () => {
    const cases = getRelativePathOfTests('test/testcases/');

    test.each(cases)(
        'parses %s correctly',
        (testFile) => {
            const parseResults = spawnSync('build/lexerParse', [testFile])
            expect(parseResults.error).toBeFalsy();
            expect(parseResults.stderr.length).toBe(0);
            expect(parseResults.stdout.toString()).toMatchSnapshot();
        }
    );
})