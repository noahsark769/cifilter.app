import React from 'react';
import styled from 'styled-components';
import TitleMark from './TitleMark';

const Container = styled.div`
    width: 100%;
    padding-top: 100px;
    display: flex;
    flex-direction: column;
    align-items: center;
`;

const P = styled.p`
    font-size: 14px;
    color: #333;
    padding-top: 20px;
    max-width: 500px;
    line-height: 18px;
    text-align: left;
    width: 100%;

    @media (prefers-color-scheme: dark) {
        color: #fff;
    }
`;
const LI = styled.li`
    font-size: 14px;
    color: #333;
    padding-top: 20px;
    max-width: 500px;
    line-height: 18px;
    list-style-type: decimal;
    margin-left: 40px;
    &::before {
        content: "";
        width: 3px;
        display: inline-block;
    }

    @media (prefers-color-scheme: dark) {
        color: #fff;
    }
`;

const OL = styled.ol`
    max-width: 500px;
`;

const A = styled.a`
    color: #74AEDF;
`;

const EmptyFilterDetail = (props) => {
    return (
        <Container>
            <TitleMark />
            <P>CIFilter.app is an <A href="https://github.com/noahsark769/cifilter.app">open source</A> <A href="https://developer.apple.com/documentation/coreimage/cifilter">CIFilter</A> documentation project. It has two parts:</P>
            <OL>
                <LI>This website, which lists all available CIFilters, their information, and examples of applying them</LI>
                <LI><A href="https://itunes.apple.com/us/app/cifilter-io/id1457458557?mt=8">An app</A> which allows you to apply each CIFilter to various inputs, tune their parameters, and apply them to camera and photo library images</LI>
            </OL>
            <P>This website is completely free and will be updated with each new release of iOS and macOS.</P>
            <P>If you'd like to support this project, please consider downloading <A href="https://itunes.apple.com/us/app/cifilter-io/id1457458557?mt=8">the app</A> - your purchase supports CIFilter.io and other projects like it.</P>
            <P>To learn more about CIFilter.app, check out this <A href="https://noahgilmore.com/blog/cifilterio/">blog post</A>.</P>
            <P>To get started, select a CIFilter from the left.</P>
        </Container>
    );
};
export default EmptyFilterDetail;