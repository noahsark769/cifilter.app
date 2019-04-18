import React from 'react';
import styled from 'styled-components';
import Logo from './Logo';

const LogoWrapper = styled.div`
    display: inline-block;
    width: 30px;
    height: 30px;
`;

const Title = styled.div`
    font-size: 20px;
    font-weight: bold;
    display: inline-block;
`;

const LogoAndTitle = styled.div`
    display: flex;
    flex-direction: horizontal;
    align-items: center;
`;

const TitleMark = (props) => {
    return (
        <LogoAndTitle>
            <LogoWrapper className="margin-right--sm">
                <Logo />
            </LogoWrapper>
            <Title>CIFilter.io</Title>
        </LogoAndTitle>
    );
};
export default TitleMark;