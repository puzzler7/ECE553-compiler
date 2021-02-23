const fs = require('fs');
const { spawnSync } = require('child_process');
const { test, it } = require('@jest/globals');

const getRelativePathOfTests = (dir) => {
    return fs.readdirSync(dir)
             .filter(fileName => /^.*\.tig$/.exec(fileName))
             .map(fileName => dir + fileName);

}

const negativeTestPattern = /\/\*.*error.*\*\//;
const binaryName = `parserParse-${process.platform}`;

describe('When building with Mlton', () => {
    it('checks that Mlton exists and builds lexer without crashing', () => {
        const checkMltonExists = spawnSync('mlton')
        expect(checkMltonExists.error).toBeFalsy();
        expect(checkMltonExists.stdout.toString().includes('MLton')).toBeTruthy();

        const checkBuild = spawnSync('mlton', [
            '-default-ann',
            'allowVectorExps true',
            '-output',
            `build/${binaryName}`,
            'src/parser/sources.mlb'
        ]);
        expect(checkBuild.error).toBeFalsy();
        expect(checkBuild.stderr.toString().length).toBe(0);
    });
})

describe('The textbook tests', () => {
    const cases = getRelativePathOfTests('test/testcases/');
    /*
    const negativeTests = cases.filter(testFile => 
        negativeTestPattern.test(fs.readFileSync(testFile, {encoding: 'utf8'}))
    )
    const positiveTests = cases.filter()
    */

    test.each(cases)(
        'parses %s correctly',
        (testFile) => {
            
            const parseResults = spawnSync(`build/${binaryName}`, [testFile])
            expect(parseResults.error).toBeFalsy();
            expect(parseResults.stderr.toString()).toBe('');
            expect(parseResults.stdout.toString()).toMatchSnapshot();
            expect(errorMessagePattern.test(parseResults.stdout.toString())).toBeFalsy();
        }
    );
})